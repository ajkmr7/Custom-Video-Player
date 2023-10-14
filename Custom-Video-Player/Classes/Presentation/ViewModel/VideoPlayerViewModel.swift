import AVFoundation

enum PlayerState {
    case play
    case pause
}

public class VideoPlayerViewModel {
    private let seekDuration: Float64 = 15
    var playerState: PlayerState = .pause
    var config: VideoPlayerConfig

    var url: URL? {
        guard let videos = config.playlist.videos, videos.count > 0, let url = videos[config.playlist.currentVideoIndex ?? 0].url else { return nil }
        return URL(string: url)
    }
    
    var titleLabelText: String {
        return config.playlist.title
    }
    
    var subtitleLabelText: String? {
        guard let videos = config.playlist.videos, videos.count > 0, let title = videos[config.playlist.currentVideoIndex ?? 0].title else { return nil }
        return title
    }

    public init(config: VideoPlayerConfig) {
        self.config = config
    }

    func getForwardTime(currentTime: CMTime, duration: CMTime) -> CMTime? {
        let playerCurrentTime = CMTimeGetSeconds(currentTime)
        let newTime = playerCurrentTime + seekDuration

        if newTime < CMTimeGetSeconds(duration) {
            return CMTimeMake(Int64(newTime * 1000 as Float64), 1000)
        }
        return CMTimeMake(Int64(CMTimeGetSeconds(duration) * 1000 as Float64), 1000)
    }

    func getBackwardTime(currentTime: CMTime) -> CMTime? {
        let playerCurrentTime = CMTimeGetSeconds(currentTime)
        var newTime = playerCurrentTime - seekDuration

        if newTime < 0 {
            newTime = 0
        }
        return CMTimeMake(Int64(newTime * 1000 as Float64), 1000)
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
}

