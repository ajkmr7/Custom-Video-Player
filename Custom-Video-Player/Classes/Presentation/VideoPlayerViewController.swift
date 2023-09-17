import UIKit
import AVKit

public class VideoPlayerViewController: UIViewController {
    private let videoURL: URL
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    
    // Custom Subtitle Styling
    private let subtitleStyling = AVTextStyleRule(textMarkupAttributes: [
        kCMTextMarkupAttribute_CharacterBackgroundColorARGB as String: [0.0, 0.0, 0.0, 0.4],
        kCMTextMarkupAttribute_ForegroundColorARGB as String: [1.0, 1.0, 1.0, 1.0],
        kCMTextMarkupAttribute_FontFamilyName as String: UIFont.preferredFont(forTextStyle: .body).fontName,
    ])
    
    public init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        setupControls()
        resumePlayer()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }
    
    private func setupPlayer() {
        playerItem = AVPlayerItem(url: videoURL)
        if let subtitleStyling = subtitleStyling {
            playerItem?.textStyleRules = [subtitleStyling]
        }
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        guard let playerLayer = playerLayer else { return }
        view.backgroundColor = .black
        view.layer.addSublayer(playerLayer)
    }
    
    private func setupControls() {
        addSubtitleButton()
    }
    
    private func resumePlayer() {
        player?.play()
    }
}

// MARK: - Subtitle Functionality

extension VideoPlayerViewController {
    
    private func addSubtitleButton() {
        if #available(iOS 13.0, *) {
            let subtitleButton = UIBarButtonItem(image: UIImage(systemName: "captions.bubble"), style: .plain, target: self, action: #selector(showSubtitleOptions))
            navigationItem.rightBarButtonItem = subtitleButton
        }
    }
    
    @objc private func showSubtitleOptions() {
        guard let supportedSubtitleOptions = player?.supportedSubtitleOptions else { return }
        
        let alertController = UIAlertController(title: "Select Subtitle", message: nil, preferredStyle: .actionSheet)
        
        for option in supportedSubtitleOptions {
            alertController.addAction(UIAlertAction(title: option.displayName, style: .default) { _ in
                self.handleSubtitleSelection(option: option)
            })
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func handleSubtitleSelection(option: AVMediaSelectionOption) {
        guard let mediaSelectionGroup = playerItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return }
        playerItem?.select(option, in: mediaSelectionGroup)
    }
}


