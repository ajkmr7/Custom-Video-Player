import Foundation

protocol Configurable {}

extension NSObject: Configurable {}

/// Extension to provide a default implementation of the configuration method for `Configurable` types.
extension Configurable where Self: AnyObject {
    
    /// Configures the instance using a closure and returns the configured instance.
    ///
    /// This method allows for a fluent interface style of configuring objects.
    ///
    /// - Parameter transform: A closure that takes the instance as a parameter and configures it.
    /// - Returns: The configured instance.
    @discardableResult
    func configure(_ transform: (Self) -> Void) -> Self {
        transform(self)
        return self
    }
}
