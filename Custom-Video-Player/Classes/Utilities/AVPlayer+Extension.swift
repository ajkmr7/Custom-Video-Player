import AVFoundation

/// Extension to AVPlayer providing additional functionalities such as subtitle options and stream bitrate control.
extension AVPlayer {
    
    /// Returns the supported subtitle options for the current player item.
    ///
    /// - Returns: An array of `AVMediaSelectionOption` objects representing the available subtitles, or `nil` if none are available.
    var supportedSubtitleOptions: [AVMediaSelectionOption]? {
        guard let playerItem = currentItem,
              let mediaSelectionGroup = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else {
            return nil
        }
        return mediaSelectionGroup.options.filter { $0.extendedLanguageTag != nil }
    }
    
    /// Sets the preferred peak bitrate for the current player item.
    ///
    /// - Parameter bitrate: The desired bitrate in bits per second. Use `nil` to set to the maximum available bitrate.
    func setStreamBitrate(bitrate: Double?) {
        currentItem?.preferredPeakBitRate = bitrate ?? Double.greatestFiniteMagnitude
    }
}
