import Foundation

protocol Configurable {}

extension NSObject: Configurable {}

extension Configurable where Self: AnyObject {
    @discardableResult
    func configure(_ transform: (Self) -> Void) -> Self {
        transform(self)
        return self
    }
}
