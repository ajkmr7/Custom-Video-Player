import Foundation

class QualitySelectionViewModel {
    // MARK: - Properties
    
    var supportedResolutions: [String]

    var selectedItemIndex: Int = 0

    // MARK: - Initialization
    
    /// Initializes the view model with supported resolutions.
    ///
    /// - Parameter supportedResolutions: Array of supported resolutions.
    init(supportedResolutions: [String]) {
        self.supportedResolutions = supportedResolutions
    }
}