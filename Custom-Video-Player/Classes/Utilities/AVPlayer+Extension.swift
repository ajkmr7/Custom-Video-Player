import AVFoundation

extension AVPlayer {
    var supportedSubtitleOptions: [AVMediaSelectionOption]? {
        guard let playerItem = currentItem, let mediaSelectionGroup = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible)
        else {
            return nil
        }
        return mediaSelectionGroup.options.filter { $0.extendedLanguageTag != nil }
    }
}
