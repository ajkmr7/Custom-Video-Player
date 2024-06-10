import AVFoundation
import Foundation

class SubtitleSelectionViewModel {
    // MARK: - Properties
    
    private var supportedLanguages: [AVMediaSelectionOption]
    
    private var subtitleOptions: [String]
    
    var selectedItemIndex: Int = 0
    
    var subtitleOptionsCount: Int {
        subtitleOptions.count
    }
    
    /// Closure to get the subtitle option string at a given index.
    var subtitleOption: (Int) -> String {
        return { index in
            self.subtitleOptions[index]
        }
    }
    
    /// The selected subtitle track.
    var subtitleTrack: AVMediaSelectionOption? {
        selectedItemIndex == 0 ? nil : supportedLanguages[selectedItemIndex - 1]
    }
    
    // MARK: - Initialization
    
    /// Initializes the view model with supported subtitle languages.
    ///
    /// - Parameter supportedLanguages: Array of supported subtitle options.
    init(supportedLanguages: [AVMediaSelectionOption]) {
        self.supportedLanguages = supportedLanguages
        subtitleOptions = ["Off"] + supportedLanguages.map {
            $0.displayName(with: Locale(identifier: "en-EN"))
        }
    }
}
