import UIKit

public final class VideoPlayerCoordinator {
    public let navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController =  navigationController
    }

    public func invoke(videoPlayerConfig: VideoPlayerConfig, partyID: String? = nil, chatName: String? = nil) {
        let viewModel = VideoPlayerViewModel(videoPlayerConfig: videoPlayerConfig, partyID: partyID, chatName: chatName)
        let videoPlayer = VideoPlayerViewController(viewModel: viewModel, coordinator: self)
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true)
        }
        videoPlayer.modalPresentationStyle = .fullScreen
        navigationController.present(videoPlayer, animated: true)
    }
}
