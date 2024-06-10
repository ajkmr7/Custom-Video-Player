import UIKit

/// A protocol for assets that have a name and optionally a namespace.
protocol NameableAsset: RawRepresentable where RawValue == String {
    var namespace: String? { get }
}

extension NameableAsset where RawValue == String {
    /// Default implementation for the namespace property. Returns nil by default.
    var namespace: String? { nil }
}

extension UIColor {
    /// Convenience initializer to create a UIColor from a NameableAsset.
    ///
    /// - Parameter color: The NameableAsset representing the color.
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

extension UIImage {
    /// Convenience initializer to create a UIImage from a NameableAsset.
    ///
    /// - Parameters:
    ///   - image: The NameableAsset representing the image.
    ///   - resourceBundle: The bundle containing the image resources.
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
