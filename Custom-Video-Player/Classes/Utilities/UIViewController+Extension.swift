import UIKit

extension UIViewController {
    func resetOrientation(_ orientation: UIInterfaceOrientationMask) {
        let value = orientation.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
}
