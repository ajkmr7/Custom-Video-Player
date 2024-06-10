import UIKit

/// A coordinator responsible for presenting the video player.
public final class VideoPlayerCoordinator {
    /// The navigation controller where the video player will be presented.
    public let navigationController: UINavigationController

    /// Initializes a new instance of `VideoPlayerCoordinator`.
    ///
    /// - Parameter navigationController: The navigation controller where the video player will be presented.
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    /// Invokes the video player with the given configuration.
    ///
    /// - Parameter videoPlayerConfig: The configuration for the video player.
    public func invoke(videoPlayerConfig: VideoPlayerConfig) {
        let viewModel = VideoPlayerViewModel(useCase: VideoPlayerService(), config: videoPlayerConfig)
        let videoPlayer = VideoPlayerViewController(viewModel: viewModel, coordinator: self)
        
        // Dismiss any presented view controller before presenting the video player
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true)
        }
        
        // Present the video player modally with full screen presentation style
        videoPlayer.modalPresentationStyle = .fullScreen
        navigationController.present(videoPlayer, animated: true)
    }
}
