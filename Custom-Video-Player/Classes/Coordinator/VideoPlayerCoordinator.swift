import UIKit

public final class VideoPlayerCoordinator {
    public let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController =  navigationController
    }

    public func invoke(videoPlayerConfig: VideoPlayerConfig) {
        let viewModel = VideoPlayerViewModel(useCase: VideoPlayerService(), config: videoPlayerConfig)
        let videoPlayer = VideoPlayerViewController(viewModel: viewModel, coordinator: self)
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true)
        }
        videoPlayer.modalPresentationStyle = .fullScreen
        navigationController.present(videoPlayer, animated: true)
    }
}
