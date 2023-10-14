import AVFoundation
import AVKit

extension CMTime {
    
    /// Returns duration in ` h:mm:ss` format  for hour-long video else returns duration in `mm:ss` format
    
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
