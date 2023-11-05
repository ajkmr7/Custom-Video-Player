import Foundation

class QualitySelectionViewModel {
    var supportedResolutions: [String]
    var selectedItemIndex: Int = 0

    init(supportedResolutions: [String]) {
        self.supportedResolutions = supportedResolutions
    }
}
