import UIKit
import AVKit
import AVFoundation

public class VideoPlayerViewController: UIViewController {
    let viewModel: VideoPlayerViewModel
    let coordinator: VideoPlayerCoordinator
    
    private var periodicTimeObserver: Any?
    private var didSetupControls: Bool = false
    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    let playerControlsView = PlayerControlsView()
    
    private let notification = NotificationCenter.default
    
    // Custom Subtitle Styling
    private let subtitleStyling = AVTextStyleRule(textMarkupAttributes: [
        kCMTextMarkupAttribute_CharacterBackgroundColorARGB as String: [0.0, 0.0, 0.0, 0.4],
        kCMTextMarkupAttribute_ForegroundColorARGB as String: [1.0, 1.0, 1.0, 1.0],
        kCMTextMarkupAttribute_FontFamilyName as String: UIFont.preferredFont(forTextStyle: .body).fontName,
    ])
    
    public init(viewModel: VideoPlayerViewModel, coordinator: VideoPlayerCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override public func viewWillAppear(_: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
    }

    override public func viewWillDisappear(_: Bool) {
        resetOrientation(UIInterfaceOrientationMask.portrait)
        UIViewController.attemptRotationToDeviceOrientation()
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        resetOrientation(UIInterfaceOrientationMask.landscapeRight)
        UIViewController.attemptRotationToDeviceOrientation()
        notification.addObserver(self, selector: #selector(appMovedToBackground), name: .UIApplicationDidEnterBackground, object: nil)
        setupPlayer()
    }

    @objc func shouldForceLandscape() {
        //  View controller that response this protocol can rotate ...
    }

    @objc func appMovedToBackground() {
        pausePlayer()
    }

    public override var shouldAutorotate: Bool {
        return true
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }
    
    private func setupPlayer() {
        guard let videoURL = viewModel.url else { return }
        playerItem = AVPlayerItem(url: videoURL)
        if let subtitleStyling = subtitleStyling {
            playerItem?.textStyleRules = [subtitleStyling]
        }
        player = AVPlayer(playerItem: playerItem)
        addObservers()
        playerLayer = AVPlayerLayer(player: player)
        guard let playerLayer = playerLayer else { return }
        view.backgroundColor = .black
        view.layer.addSublayer(playerLayer)
    }
    
    private func setupControls() {
        guard let totalDuration = player?.currentItem?.duration else { return }
        playerControlsView.totalTimeLabelText = viewModel.getFormattedTime(totalDuration: totalDuration.seconds)
        playerControlsView.titleLabelText = viewModel.titleLabelText
        playerControlsView.subtitleLabelText = viewModel.subtitleLabelText
        view.addSubview(playerControlsView)
        playerControlsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        playerControlsView.delegate = self
    }
    
    func pausePlayer() {
        guard viewModel.playerState == .play else { return }
        player?.pause()
        playerControlsView.playPauseButtonImage = VideoPlayerImage.playButton.uiImage
        viewModel.playerState = .pause
    }

    func resumePlayer() {
        guard viewModel.playerState == .pause else { return }
        player?.play()
        playerControlsView.playPauseButtonImage = VideoPlayerImage.pauseButton.uiImage
        viewModel.playerState = .play
    }
}

// MARK: - Observers

extension VideoPlayerViewController {
    private func addObservers() {
        playerItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        periodicTimeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
            guard let self = self else { return }
            if self.player?.currentItem?.status == .readyToPlay {
                self.playerControlsView.seekBarValue = Float(time.seconds)
                self.playerControlsView.currentTimeLabelText = time.durationText + "/"
            }
        }
    }

    public override func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "duration":
            if let duration = player?.currentItem?.duration, duration.seconds > 0.0, !didSetupControls {
                handleDuration(duration.seconds)
                resumePlayer()
            }
        default:
            break
        }
    }

    private func handleDuration(_ duration: Double) {
        playerControlsView.seekBarMaximumValue = Float(duration)
        setupControls()
        didSetupControls = true
    }
}

// MARK: - Subtitle Functionality

extension VideoPlayerViewController {
    
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


