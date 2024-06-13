import UIKit
import SnapKit
import CustomVideoPlayer

class ViewController: UIViewController {
    var viewModel: ViewModel?
    var joinWatchPartyAlert: UIAlertController?
    
    let playButton: UIButton = {
        let button = UIButton()
        button.setTitle("Play Video", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(navigatoToVideoPlayer), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ViewModel()
        view.backgroundColor = .white

        view.addSubview(playButton)
    
        playButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(34)
        }
    }
    
    func setupJoinWatchPartyAlertView() {
        if joinWatchPartyAlert == nil {
            joinWatchPartyAlert = UIAlertController(
                title: "Let’s get the party started",
                message: "Watch and chat with your friends and family.",
                preferredStyle: .alert
            )
            joinWatchPartyAlert?.addTextField { textField in
                textField.placeholder = "Chat Name"
            }
            joinWatchPartyAlert?.addAction(UIAlertAction(title: "Join", style: .default) { [weak self] _ in
                if let textField = self?.joinWatchPartyAlert?.textFields?.first {
                    if let partyID = self?.viewModel?.partyID {
                        if let chatName = textField.text, !chatName.isEmpty {
                            self?.navigateToWatchParty(partyID: partyID, chatName: chatName)
                        } else {
                            self?.navigateToWatchParty(partyID: partyID, chatName: "Participant")
                        }
                    }
                }
            })
            joinWatchPartyAlert?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
    }

    @objc func navigatoToVideoPlayer() {
        guard let navigationController = navigationController else { return }
        let playlist = VideoPlaylist(
            title: "Playlist",
            videos: [
                Video(
                    url: "https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
                    title: "Video"
                )
            ]
        )
        let config = VideoPlayerConfig(playlist: playlist)
        let coordinator = VideoPlayerCoordinator(navigationController: navigationController)
        coordinator.invoke(videoPlayerConfig: config)
    }
    
    @objc func navigateToWatchParty(partyID: String, chatName: String) {
        guard let navigationController = navigationController else { return }
        viewModel?.fetchVideoPlayerConfig(for: partyID) { config in
            guard let config = config else { return }
            let coordinator = VideoPlayerCoordinator(navigationController: navigationController)
            coordinator.invoke(videoPlayerConfig: config, partyID: partyID, chatName: chatName)
        }
    }
}

