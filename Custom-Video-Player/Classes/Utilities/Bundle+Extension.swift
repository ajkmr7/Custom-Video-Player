import Foundation

/// A class for handling the resources associated with the custom video player.
final class CustomVideoPlayer {
    
    /// The bundle containing the resources for the custom video player.
    static let resourceBundle: Bundle = {
        let myBundle = Bundle(for: CustomVideoPlayer.self)

        // Ensure the URL for the resource bundle is found.
        guard let resourceBundleURL = myBundle.url(forResource: "Custom-Video-Player", withExtension: "bundle") else {
            fatalError("Custom-Video-Player.bundle not found!")
        }

        // Ensure the resource bundle is accessible.
        guard let resourceBundle = Bundle(url: resourceBundleURL) else {
            fatalError("Cannot access Custom-Video-Player.bundle!")
        }

        return resourceBundle
    }()
}
