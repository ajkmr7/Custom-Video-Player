import Foundation

public extension UIView {
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
