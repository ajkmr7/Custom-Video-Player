import UIKit
import SnapKit
import Custom_Video_Player

class ViewController: UIViewController {
    
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
        view.backgroundColor = .white

        view.addSubview(playButton)
    
        playButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(34)
        }
    }

    @objc private func navigatoToVideoPlayer() {
        guard let navigationController = navigationController else { return }
        let playlist = VideoPlaylist(
            title: "Playlist",
            videos: [
                Video(
                    url: "https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
                    title: "Video 1"
                ),
                Video(
                    url: "https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
                    title: "Video 2"
                ),
                Video(
                    url: "https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
                    title: "Video 3"
                )
            ]
        )
        let config = VideoPlayerConfig(playlist: playlist)
        let coordinator = VideoPlayerCoordinator(navigationController: navigationController)
        coordinator.invoke(videoPlayerConfig: config)
    }
}

