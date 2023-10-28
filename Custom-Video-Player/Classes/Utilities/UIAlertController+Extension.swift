import Foundation

// TODO: Fix orientation issue for watch party alert view

extension UIAlertController {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .all }
}
