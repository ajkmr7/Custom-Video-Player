import AVFoundation
import AVKit

/// Extension to CMTime providing additional functionality for formatting duration text.
extension CMTime {
    
    /// Returns the duration in `h:mm:ss` format for hour-long videos or `mm:ss` format for shorter videos.
    ///
    /// - Returns: A string representing the formatted duration.
    var durationText: String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours = Int(totalSeconds.truncatingRemainder(dividingBy: 86400) / 3600)
        let minutes = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))

        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        }
        return String(format: "%02i:%02i", minutes, seconds)
    }
}
