import Foundation

extension UIAlertController {
    @objc func shouldForceLandscape() {
        //  View controller that response this protocol can rotate ...
    }
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .all }
}
