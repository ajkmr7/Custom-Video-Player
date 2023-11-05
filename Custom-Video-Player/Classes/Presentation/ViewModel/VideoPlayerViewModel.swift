import AVFoundation

enum PlayerState {
    case play
    case pause
}

protocol VideoPlayerDelegate: AnyObject {
    func didFinishFetchingVideoQualityInformationWithSuccess()
    func didFinishFetchingVideoQualityInformationWithFailure()
}

public class VideoPlayerViewModel {
    private let seekDuration: Float64 = 15
    var playerState: PlayerState = .pause
    var config: VideoPlayerConfig
    private let useCase: VideoPlayerUseCase
    private var playbackQualities: [VideoQuality]?
    var playbackQualityStrings: [String]?
    weak var delegate: VideoPlayerDelegate?
    
    var url: URL? {
        guard let videos = config.playlist.videos, videos.count > 0, let url = videos[config.playlist.currentVideoIndex ?? 0].url else { return nil }
        return URL(string: url)
    }
    
    var isPreviousButtonEnabled: Bool {
        let currentVideoIndex = config.playlist.currentVideoIndex ?? 0
        if currentVideoIndex - 1 >= 0 {
            return true
        }
        return false
    }
    
    
    var isNextButtonEnabled: Bool {
        let currentVideoIndex = config.playlist.currentVideoIndex ?? 0
        if currentVideoIndex + 1 == config.playlist.videos?.count {
            return false
        }
        return true
    }

    var titleLabelText: String {
        return config.playlist.title
    }
    
    var subtitleLabelText: String? {
        guard let videos = config.playlist.videos, videos.count > 0, let title = videos[config.playlist.currentVideoIndex ?? 0].title else { return nil }
        return title
    }
    
    public init(
        useCase: VideoPlayerUseCase,
        config: VideoPlayerConfig
    ) {
        self.useCase = useCase
        self.config = config
    }
    
    // MARK: - AVPlayer Time
    
    func getForwardTime(currentTime: CMTime, duration: CMTime) -> CMTime? {
        let playerCurrentTime = CMTimeGetSeconds(currentTime)
        let newTime = playerCurrentTime + seekDuration
        
        if newTime < CMTimeGetSeconds(duration) {
            return CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        }
        return CMTimeMake(value: Int64(CMTimeGetSeconds(duration) * 1000 as Float64), timescale: 1000)
    }
    
    func getBackwardTime(currentTime: CMTime) -> CMTime? {
        let playerCurrentTime = CMTimeGetSeconds(currentTime)
        var newTime = playerCurrentTime - seekDuration
        
        if newTime < 0 {
            newTime = 0
        }
        return CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
    }
    
    func getFormattedTime(totalDuration: Double) -> String {
        let hours = Int(totalDuration.truncatingRemainder(dividingBy: 86400) / 3600)
        let minutes = Int(totalDuration.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = Int(totalDuration.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        }
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    // MARK: - Video Quality
    
    func fetchSupportedVideoQualites() {
        guard let url = url else { return }
        let helper = M3u8Helper()
        useCase.getM3U8Config(videoURL: url, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                self.playbackQualities = helper.fetchSupportedVideoQualities(with: data)
                self.playbackQualityStrings = self.playbackQualities?.map(\.resolution)
                self.delegate?.didFinishFetchingVideoQualityInformationWithSuccess()
            case .failure:
                self.delegate?.didFinishFetchingVideoQualityInformationWithFailure()
            }
        })
    }
    
    func fetchPlaybackBitrate(for index: Int) -> Double? {
        return playbackQualities?[index].bitrate
    }
}

