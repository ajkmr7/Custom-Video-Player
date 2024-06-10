import AVFoundation

enum PlayerState {
    case play
    case pause
}

/// Protocol for handling video player delegate methods.
protocol VideoPlayerDelegate: AnyObject {
    func didFinishFetchingVideoQualityInformationWithSuccess()
    func didFinishFetchingVideoQualityInformationWithFailure()
}

/// ViewModel for the video player.
public class VideoPlayerViewModel {
    // MARK: - Properties

    private let seekDuration: Float64 = 15
    var playerState: PlayerState = .pause
    var config: VideoPlayerConfig
    private let useCase: VideoPlayerUseCase
    private var playbackQualities: [VideoQuality]?
    var playbackQualityStrings: [String]?
    weak var delegate: VideoPlayerDelegate?
    
    /// URL of the current video.
    var url: URL? {
        guard let videos = config.playlist.videos, videos.count > 0, let url = videos[config.playlist.currentVideoIndex ?? 0].url else { return nil }
        return URL(string: url)
    }
    
    /// Indicates if the current content is live.
    var isLiveContent: Bool? {
        guard let videos = config.playlist.videos, videos.count > 0, let isLiveContent = videos[config.playlist.currentVideoIndex ?? 0].isLiveContent else { return nil }
        return isLiveContent
    }
    
    /// Indicates if the previous button is enabled.
    var isPreviousButtonEnabled: Bool {
        let currentVideoIndex = config.playlist.currentVideoIndex ?? 0
        if currentVideoIndex - 1 >= 0 {
            return true
        }
        return false
    }
    
    /// Indicates if the next button is enabled.
    var isNextButtonEnabled: Bool {
        let currentVideoIndex = config.playlist.currentVideoIndex ?? 0
        if currentVideoIndex + 1 == config.playlist.videos?.count {
            return false
        }
        return true
    }

    /// Title label text for the current video.
    var titleLabelText: String {
        return config.playlist.title
    }
    
    /// Subtitle label text for the current video.
    var subtitleLabelText: String? {
        guard let videos = config.playlist.videos, videos.count > 0, let title = videos[config.playlist.currentVideoIndex ?? 0].title else { return nil }
        return title
    }
    
    /// Initializes the video player view model.
    ///
    /// - Parameters:
    ///   - useCase: Video player use case.
    ///   - config: Video player configuration.
    public init(
        useCase: VideoPlayerUseCase,
        config: VideoPlayerConfig
    ) {
        self.useCase = useCase
        self.config = config
    }
    
    // MARK: - AVPlayer Time
    
    /// Calculates the time for seeking forward in the video.
    ///
    /// - Parameters:
    ///   - currentTime: Current time of the video.
    ///   - duration: Duration of the video.
    /// - Returns: Time for seeking forward.
    func getForwardTime(currentTime: CMTime, duration: CMTime) -> CMTime? {
        let playerCurrentTime = CMTimeGetSeconds(currentTime)
        let newTime = playerCurrentTime + seekDuration
        
        if newTime < CMTimeGetSeconds(duration) {
            return CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        }
        return CMTimeMake(value: Int64(CMTimeGetSeconds(duration) * 1000 as Float64), timescale: 1000)
    }
    
    /// Calculates the time for seeking backward in the video.
    ///
    /// - Parameter currentTime: Current time of the video.
    /// - Returns: Time for seeking backward.
    func getBackwardTime(currentTime: CMTime) -> CMTime? {
        let playerCurrentTime = CMTimeGetSeconds(currentTime)
        var newTime = playerCurrentTime - seekDuration
        
        if newTime < 0 {
            newTime = 0
        }
        return CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
    }
    
    /// Formats the total duration of the video.
    ///
    /// - Parameter totalDuration: Total duration of the video.
    /// - Returns: Formatted string representing the duration.
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
    
    /// Fetches supported video qualities.
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
    
    /// Fetches the playback bitrate for a given index.
    ///
    /// - Parameter index: Index of the selected quality.
    /// - Returns: Bitrate of the selected quality.
    func fetchPlaybackBitrate(for index: Int) -> Double? {
        return playbackQualities?[index].bitrate
    }
}