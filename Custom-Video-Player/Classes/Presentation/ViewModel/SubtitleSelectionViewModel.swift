import AVFoundation
import Foundation

class SubtitleSelectionViewModel {
    private var supportedLanguages: [AVMediaSelectionOption]
    private var subtitleOptions: [String]
    var selectedItemIndex: Int = 0
    var subtitleOptionsCount: Int {
        subtitleOptions.count
    }
    
    var subtitleOption: (Int) -> String {
        return { index in
            self.subtitleOptions[index]
        }
    }
    
    var subtitleTrack: AVMediaSelectionOption? {
        selectedItemIndex == 0 ? nil : supportedLanguages[selectedItemIndex - 1]
    }
    
    init(supportedLanguages: [AVMediaSelectionOption]) {
        self.supportedLanguages = supportedLanguages
        subtitleOptions = ["Off"] + supportedLanguages.map {
            $0.displayName(with: Locale(identifier: "en-EN"))
        }
    }
}
