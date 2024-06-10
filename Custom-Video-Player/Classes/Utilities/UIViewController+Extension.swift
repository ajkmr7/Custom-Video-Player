import UIKit

/// Extension to UIViewController providing a method to reset the device orientation.
extension UIViewController {
    
    /// Resets the device orientation to the specified orientation mask.
    ///
    /// - Parameter orientation: The orientation mask to be set.
    func resetOrientation(_ orientation: UIInterfaceOrientationMask) {
        let value = orientation.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
}
