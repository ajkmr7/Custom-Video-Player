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
            title: "IPTV",
            videos: [
                Video(
                    url: "https://ndtvindiaelemarchana.akamaized.net/hls/live/2003679/ndtvindia/master.m3u8",
                    title: "NDTV",
                    isLiveContent: true
                ),
                Video(
                    url: "https://prod-sports-north-gm.jiocinema.com/bpk-tv/Colors_Tamil_HD_voot_MOB/Fallback/Colors_Tamil_HD_voot_MOB-audio_98835_tam=98800-video=560800.m3u8",
                    title: "Colors Tamil",
                    isLiveContent: true
                ),
                Video(
                    url: "https://prod-sports-north-gm.jiocinema.com/bpk-tv/Nick_Junior_voot_MOB/Fallback/Nick_Junior_voot_MOB-audio_98836_eng=98800-video=699600.m3u8",
                    title: "Nick Jr.",
                    isLiveContent: true
                ),
                Video(
                    url: "https://segment.yuppcdn.net/050522/murasu/050522/murasu_1200/chunks.m3u8",
                    title: "Murasu",
                    isLiveContent: true
                ),
                Video(
                    url: "https://ndtv24x7elemarchana.akamaized.net/hls/live/2003678/ndtv24x7/masterp_480p@1.m3u8",
                    title: "NDTV.com",
                    isLiveContent: true
                ),
            ]
        )
        let config = VideoPlayerConfig(playlist: playlist)
        let coordinator = VideoPlayerCoordinator(navigationController: navigationController)
        coordinator.invoke(videoPlayerConfig: config)
    }
}

