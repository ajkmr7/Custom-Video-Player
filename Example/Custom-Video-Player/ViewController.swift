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
        let videoPlayerVC = VideoPlayerViewController(videoURL: URL(string: "https://bitmovin-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
        navigationController?.pushViewController(videoPlayerVC, animated: true)
    }
}

