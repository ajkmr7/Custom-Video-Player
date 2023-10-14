import Foundation

public protocol Configurable {}

extension NSObject: Configurable {}

public extension Configurable where Self: AnyObject {
    @discardableResult
    func configure(_ transform: (Self) -> Void) -> Self {
        transform(self)
        return self
    }
}
