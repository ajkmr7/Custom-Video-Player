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
    var qualitySelectionView: QualitySelectionViewController?
    
    // Custom Subtitle Styling
    private let subtitleStyling = AVTextStyleRule(textMarkupAttributes: [
        kCMTextMarkupAttribute_CharacterBackgroundColorARGB as String: [0.0, 0.0, 0.0, 0.4],
        kCMTextMarkupAttribute_ForegroundColorARGB as String: [1.0, 1.0, 1.0, 1.0],
        kCMTextMarkupAttribute_FontFamilyName as String: UIFont.preferredFont(forTextStyle: .body).fontName,
    ])
    
    private let activityIndicatorView = UIActivityIndicatorView().configure {
        $0.tintColor = .gray
        $0.color = .gray
        $0.hidesWhenStopped = true
    }
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        addLoader()
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
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self,
                                    name: UIApplication.didEnterBackgroundNotification,
                                    object: nil)
        guard let isLiveContent = viewModel.isLiveContent, !isLiveContent else { return }
        if let periodicTimeObserver = periodicTimeObserver {
            player?.removeTimeObserver(periodicTimeObserver)
        }
        periodicTimeObserver = nil
        player?.currentItem?.removeObserver(self, forKeyPath: "duration")
        player?.cancelPendingPrerolls()
        player?.replaceCurrentItem(with: nil)
        invalidateControlsHiddenTimer()
    }
}

// MARK: - Video Player Setup

extension VideoPlayerViewController {
    private func addLoader() {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.centerX.equalTo(view.snp.centerX)
        }
    }

    private func setupPlayer() {
        guard let videoURL = viewModel.url else { return }
        activityIndicatorView.startAnimating()
        playerItem = AVPlayerItem(url: videoURL)
        if let subtitleStyling = subtitleStyling {
            playerItem?.textStyleRules = [subtitleStyling]
        }
        player = AVPlayer(playerItem: playerItem)
        addObservers()
        fetchSupportedQualities()
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
        playerControlsView.previousVideoButtonState = viewModel.isPreviousButtonEnabled
        playerControlsView.nextVideoButtonState = viewModel.isNextButtonEnabled
        view.addSubview(playerControlsView)
        playerControlsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        playerControlsView.delegate = self
        setupGestureRecognizers()
        setupSubtiteSelectionView()
    }
    
    private func setupLiveControls() {
        playerControlsView.titleLabelText = viewModel.titleLabelText
        playerControlsView.subtitleLabelText = viewModel.subtitleLabelText
        playerControlsView.previousVideoButtonState = viewModel.isPreviousButtonEnabled
        playerControlsView.nextVideoButtonState = viewModel.isNextButtonEnabled
        view.addSubview(playerControlsView)
        playerControlsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        playerControlsView.delegate = self
        setupGestureRecognizers()
        playerControlsView.enableLiveControls()
    }
    
    private func setupSubtiteSelectionView() {
        guard let supportedLanguages = player?.supportedSubtitleOptions, !supportedLanguages.isEmpty else {
            playerControlsView.disableSubtitlesButton()
            return
        }
        subtitleSelectionView = SubtitleSelectionViewController(viewModel: .init(supportedLanguages: supportedLanguages))
        subtitleSelectionView?.delegate = self
    }
    
    func setupQualitySelectionView() {
        guard let playbackQualityStrings = viewModel.playbackQualityStrings, !playbackQualityStrings.isEmpty else {
            return
        }
        playerControlsView.unhideSettingsButton()
        qualitySelectionView = QualitySelectionViewController(viewModel: .init(supportedResolutions: playbackQualityStrings))
        qualitySelectionView?.delegate = self
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
    
    private func fetchSupportedQualities() {
        viewModel.delegate = self
        viewModel.fetchSupportedVideoQualites()
    }
}

// MARK: - Observers

extension VideoPlayerViewController {
    private func addObservers() {
        playerItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        guard let isLiveContent = viewModel.isLiveContent, !isLiveContent else { return }
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
                activityIndicatorView.stopAnimating()
                playerControlsView.seekBarMaximumValue = Float(duration.seconds)
                enableControls()
                resumePlayer()
            }
        case "status":
            switch player?.currentItem?.status {
            case .readyToPlay:
                if let isLiveContent = viewModel.isLiveContent, isLiveContent, !didSetupControls {
                    activityIndicatorView.stopAnimating()
                    playerControlsView.seekBarValue = 1
                    playerControlsView.seekBarMaximumValue = 1
                    enableControls()
                    resumePlayer()
                }
            case .failed:
                activityIndicatorView.stopAnimating()
                handlePlayerError(player?.currentItem?.error)
            default:
                break
            }
        default:
            break
        }
    }
    
    private func enableControls() {
        if let isLiveContent = viewModel.isLiveContent, isLiveContent {
            setupLiveControls()
        } else {
            setupControls()
        }
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

// MARK: - Reset Player

extension VideoPlayerViewController {
    func resetPlayer(with currentVideoIndex: Int) {
        resetPlayerItems()
        viewModel.config.playlist.currentVideoIndex = currentVideoIndex
        resetControlsHiddenTimer()
        playerControlsView.seekBarValue = 0
        playerControlsView.currentTimeLabelText = "00:00"
        setupPlayer()
        resumePlayer()
    }
    
    func resetPlayerItems() {
        hideControls()
        didSetupControls = false
        disableGestureRecognizers()
        player?.replaceCurrentItem(with: nil)
        playerItem = nil
        playerLayer = nil
        viewModel.playerState = .pause
    }
    
    private func disableGestureRecognizers() {
        view.gestureRecognizers?.removeAll()
    }
}

