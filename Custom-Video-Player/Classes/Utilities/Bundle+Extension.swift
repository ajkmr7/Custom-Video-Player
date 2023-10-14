import Foundation

final class CustomVideoPlayer {
    static let resourceBundle: Bundle = {
        let myBundle = Bundle(for: CustomVideoPlayer.self)

        guard let resourceBundleURL = myBundle.url(
            forResource: "Custom-Video-Player", withExtension: "bundle"
        )
        else { fatalError("CustomVideoPlayer.bundle not found!") }

        guard let resourceBundle = Bundle(url: resourceBundleURL)
        else { fatalError("Cannot access CustomVideoPlayer.bundle!") }

        return resourceBundle
    }()
}
