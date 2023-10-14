import UIKit

public protocol NameableAsset: RawRepresentable where RawValue == String {
    var namespace: String? { get }
}

public extension NameableAsset where RawValue == String {
    var namespace: String? { nil }
}

public extension UIColor {
    convenience init<T: NameableAsset>(_ color: T) {
        var name = color.rawValue
        if let namespace = color.namespace {
            name = "\(namespace)/\(name)"
        }
        let resourceBundle = CustomVideoPlayer.resourceBundle
        if #available(iOS 13, *) {
            self.init(named: name, in: resourceBundle, compatibleWith: .current)!
        } else {
            self.init(named: name, in: resourceBundle, compatibleWith: nil)!
        }
    }
}

public extension UIImage {
    convenience init<T: NameableAsset>(_ image: T, resourceBundle: Bundle) {
        var name = image.rawValue
        if let namespace = image.namespace {
            name = "\(namespace)/\(name)"
        }
        if #available(iOS 13, *) {
            self.init(named: name, in: resourceBundle, compatibleWith: .current)!
        } else {
            self.init(named: name, in: resourceBundle, compatibleWith: nil)!
        }
    }
}
