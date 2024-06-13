import Foundation

/// A class for handling the resources associated with the custom video player.
final class CustomVideoPlayer {
    
    /// The bundle containing the resources for the custom video player.
    static let resourceBundle: Bundle = {
        #if SWIFT_PACKAGE
        // When using Swift Package Manager, use the module bundle.
        return Bundle.module
        #endif
        // When using Cocoapods, locate the resource bundle manually.
        let myBundle = Bundle(for: CustomVideoPlayer.self)

        // Ensure the URL for the resource bundle is found.
        guard let resourceBundleURL = myBundle.url(forResource: "ResourcesBundle", withExtension: "bundle") else {
            fatalError("ResourcesBundle.bundle not found!")
        }

        // Ensure the resource bundle is accessible.
        guard let resourceBundle = Bundle(url: resourceBundleURL) else {
            fatalError("Cannot access ResourcesBundle.bundle!")
        }

        return resourceBundle
    }()
}