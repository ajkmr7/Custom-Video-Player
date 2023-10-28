import UIKit
import AVKit
import AVFoundation

public class VideoPlayerViewController: UIViewController {
    let viewModel: VideoPlayerViewModel
    let coordinator: VideoPlayerCoordinator
    
    private var periodicTimeObserver: Any?
    private var didSetupControls: Bool = false
    private var controlsHiddenTimer: Timer?
    private let controlsHideDelay: TimeInterval = 3.0
    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    var playerItem: AVPlayerItem?
    let playerControlsView = PlayerControlsView()
    var subtitleSelectionView: SubtitleSelectionViewController?
    var participantsView: ParticipantsViewController?
    let hostWatchPartyAlert = UIAlertController(
        title: "Let’s get the party started",
        message: "Watch and chat with your friends and family.",
        preferredStyle: .alert
    ).configure {
        $0.addTextField { textField in
            textField.placeholder = "Chat Name"
        }
    }
    let leaveWatchPartyAlert = UIAlertController(
        title: "Exit Party",
        message: "Are you sure you want to exit the watch party?",
        preferredStyle: .alert
    )
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
        notification.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
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
}

// MARK: - Video Player Setup

extension VideoPlayerViewController {
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
        setupGestureRecognizers()
        setupSubtiteSelectionView()
        setupHostWatchPartyAlertView()
        setupLeaveWatchPartyAlertView()
        if viewModel.watchPartyConfig?.partyID != nil {
            onWatchPartyEntered()
        }
    }
    
    private func setupSubtiteSelectionView() {
        guard let supportedLanguages = player?.supportedSubtitleOptions, !supportedLanguages.isEmpty else {
            playerControlsView.disableSubtitlesButton()
            return
        }
        subtitleSelectionView = SubtitleSelectionViewController(viewModel: .init(supportedLanguages: supportedLanguages))
        subtitleSelectionView?.delegate = self
    }
    
    func setupParticipantsView(with participants: [String]) {
        participantsView = ParticipantsViewController(viewModel: .init(participants: participants))
    }
    
    private func setupHostWatchPartyAlertView() {
        hostWatchPartyAlert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            if let textField = self?.hostWatchPartyAlert.textFields?.first {
                if let chatName = textField.text, !chatName.isEmpty {
                    self?.viewModel.hostParty(for: chatName, currentTime: self?.player?.currentItem?.currentTime())
                } else {
                    self?.viewModel.hostParty(for: "Host", currentTime: self?.player?.currentItem?.currentTime())
                }
            }
        })
        hostWatchPartyAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewModel.watchPartyDelegate = self
    }
    
    private func setupLeaveWatchPartyAlertView() {
        leaveWatchPartyAlert.addAction(UIAlertAction(title: "Leave", style: .default) { [weak self] _ in
            self?.viewModel.leaveParty()
        })
        leaveWatchPartyAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
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
        showControls()
    }
}

// MARK: - Show/Hide Control Functionality

extension VideoPlayerViewController {
    @objc private func handleTap(_: UITapGestureRecognizer) {
        resetControlsHiddenTimer()
        playerControlsView.isHidden ? showControls() : hideControls()
    }
    
    private func showControls() {
        playerControlsView.isHidden = false
        
        UIView.animate(withDuration: 0.25) {
            self.playerControlsView.alpha = 1
        }
        resetControlsHiddenTimer()
    }
    
    @objc func hideControls() {
        UIView.animate(withDuration: 0.25) {
            self.playerControlsView.alpha = 0
        } completion: { _ in
            self.playerControlsView.isHidden = true
        }
    }
    
    func resetControlsHiddenTimer() {
        invalidateControlsHiddenTimer()
        controlsHiddenTimer = Timer.scheduledTimer(timeInterval: controlsHideDelay,
                                                   target: self,
                                                   selector: #selector(hideControlsDueToInactivity), userInfo: nil, repeats: false)
    }
    
    func invalidateControlsHiddenTimer() {
        controlsHiddenTimer?.invalidate()
        controlsHiddenTimer = nil
    }
    
    @objc private func hideControlsDueToInactivity() {
        hideControls()
    }
}
