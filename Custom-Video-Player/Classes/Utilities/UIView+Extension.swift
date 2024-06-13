import Foundation
import UIKit

extension UIView {
    func displayToast(style: ToastStyle,
                      message: String,
                      duration: CGFloat = 3.0)
    {
        let toast = PlayerToast(style: style, message: message)

        UIView.transition(with: self, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            self.addSubview(toast)
            toast.setUp()
            toast.snp.makeConstraints { make in
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            }
        }, completion: nil)

        UIView.animate(withDuration: 0.5,
                       delay: duration,
                       options: .curveEaseOut, animations: {
                           toast.alpha = 0.0
                       }, completion: { _ in
                           toast.removeFromSuperview()
                       })
    }
    func roundCorners(
        corners: CACornerMask = [.layerMinXMaxYCorner,
                                 .layerMaxXMaxYCorner,
                                 .layerMinXMinYCorner,
                                 .layerMaxXMinYCorner],
        cornerRadius: CGFloat
    ) {
        layer.maskedCorners = corners
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
}
