import MediaPlayer
import UIKit
import SnapKit

/// Delegate protocol for handling player control actions.
@objc protocol PlayerControlsViewDelegate {
    func seekForward()
    func seekBackward()
    func togglePlayPause()
    func playPreviousVideo()
    func playNextVideo()
    func goBack()
    func sliderValueChanged(slider: UISlider, event: UIEvent)
    func switchSubtitles()
    func openSettings()
    func seekToLive()
}

/// Custom view for player controls.
class PlayerControlsView: UIView {
    weak var delegate: PlayerControlsViewDelegate?
    
    // MARK: - Controls on Top
    
    private let backButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.backButton.uiImage, for: .normal)
    }
    
    private let subtitleButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.subtitlesButton.uiImage, for: .normal)
    }
    
    private let settingsButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.settingsButton.uiImage, for: .normal)
    }
    
    // MARK: - Controls on Middle
    
    private let previousVideoButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.previousVideoButton.uiImage, for: .normal)
    }
    
    private let rewindButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.rewindButton.uiImage, for: .normal)
    }
    
    private let playPauseButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.pauseButton.uiImage, for: .normal)
    }
    
    private let forwardButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.forwardButton.uiImage, for: .normal)
    }
    
    private let nextVideoButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.nextVideoButton.uiImage, for: .normal)
    }
    
    // MARK: - Controls on Bottom
    
    private let titleLabel = UILabel().configure {
        $0.font = FontUtility.helveticaNeueRegular(ofSize: 20)
        $0.textColor = VideoPlayerColor(palette: .white).uiColor
    }
    
    private let subtitleLabel = UILabel().configure {
        $0.font = FontUtility.helveticaNeueLight(ofSize: 14)
        $0.textColor = VideoPlayerColor(palette: .pearlWhite).uiColor
    }
    
    private let seekBar = UISlider().configure { seekBar in
        seekBar.maximumTrackTintColor = VideoPlayerColor(palette: .pearlWhite).uiColor
        seekBar.minimumTrackTintColor = VideoPlayerColor(palette: .red).uiColor
        seekBar.minimumValue = 0
        seekBar.setThumbImage(nil, for: .normal)
        let thumbSize = CGSize(width: CGFloat.space12, height: CGFloat.space12)
        let thumbImage = UIGraphicsImageRenderer(size: thumbSize).image { _ in
            VideoPlayerColor(palette: .red).uiColor.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: thumbSize)).fill()
        }
        seekBar.setThumbImage(thumbImage, for: .normal)
    }
    
    private let currentTimeLabel = UILabel().configure {
        $0.text = "00:00/"
        $0.font = FontUtility.helveticaNeueLight(ofSize: 14)
        $0.textColor = VideoPlayerColor(palette: .white).uiColor
    }
    
    private let totalTimeLabel = UILabel().configure {
        $0.text = "00:00"
        $0.font = FontUtility.helveticaNeueLight(ofSize: 14)
        $0.textColor = VideoPlayerColor(palette: .white).uiColor
    }
    
    private let liveButton = UIButton().configure {
        $0.backgroundColor = .clear
        $0.contentEdgeInsets = UIEdgeInsets.zero
        $0.isHidden = true
        $0.isEnabled = false
    }
    
    // MARK: - Control State Setters
    
    var playPauseButtonImage: UIImage? {
        get {
            playPauseButton.currentImage
        }
        set(newValue) {
            playPauseButton.setImage(newValue, for: .normal)
        }
    }
    
    var seekBarValue: Float {
        get {
            seekBar.value
        }
        set(newValue) {
            seekBar.value = newValue
        }
    }
    
    var seekBarMaximumValue: Float {
        get {
            seekBar.maximumValue
        }
        set(newValue) {
            seekBar.maximumValue = newValue
        }
    }
    
    var currentTimeLabelText: String? {
        get {
            currentTimeLabel.text
        }
        set(newValue) {
            currentTimeLabel.text = newValue
        }
    }
    
    var totalTimeLabelText: String? {
        get {
            totalTimeLabel.text
        }
        set(newValue) {
            totalTimeLabel.text = newValue
        }
    }
    
    var titleLabelText: String? {
        get {
            titleLabel.text
        }
        set(newValue) {
            titleLabel.text = newValue
        }
    }
    
    var subtitleLabelText: String? {
        get {
            subtitleLabel.text
        }
        set(newValue) {
            subtitleLabel.text = newValue
        }
    }
    
    var previousVideoButtonState: Bool {
        get {
            previousVideoButton.isEnabled
        }
        set(newValue) {
            previousVideoButton.isEnabled = newValue
        }
    }
    
    var nextVideoButtonState: Bool {
        get {
            nextVideoButton.isEnabled
        }
        set(newValue) {
            nextVideoButton.isEnabled = newValue
        }
    }
    
    var isPlaying: Bool = false {
        didSet {
            playPauseButtonImage = isPlaying ? VideoPlayerImage.pauseButton.uiImage : VideoPlayerImage.playButton.uiImage
        }
    }
    
        private let dynamicSpacing: CGFloat = UIScreen.main.bounds.height * 0.055
    
    init() {
        super.init(frame: .zero)
        setupViews()
        setUpEvents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Player Control Views

extension PlayerControlsView {
    private func setupViews() {
        // Setting up controls on top
        addSubview(backButton)
        addSubview(subtitleButton)
        addSubview(settingsButton)
        
        // Setting constraints for controls on top
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.space24)
            make.leading.equalToSuperview().offset(dynamicSpacing)
        }
        
        subtitleButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.top)
            make.trailing.equalTo(settingsButton.snp.leading).offset(-CGFloat.space8)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.top)
            make.trailing.equalToSuperview().offset(-dynamicSpacing)
        }
        
        // Setting up controls in the middle
        addSubview(previousVideoButton)
        addSubview(rewindButton)
        addSubview(playPauseButton)
        addSubview(forwardButton)
        addSubview(nextVideoButton)
        
        // Setting constraints for controls in the middle
        previousVideoButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(rewindButton.snp.leading).offset(-CGFloat.space16)
        }
        
        rewindButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(playPauseButton.snp.leading).offset(-CGFloat.space16)
        }
        
        playPauseButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        forwardButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(playPauseButton.snp.trailing).offset(CGFloat.space16)
        }
        
        nextVideoButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(forwardButton.snp.trailing).offset(CGFloat.space16)
        }
        
        // Setting up controls at the bottom
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(seekBar)
        addSubview(currentTimeLabel)
        addSubview(totalTimeLabel)
        addSubview(liveButton)
        
        // Setting constraints for controls at the bottom
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-CGFloat.space4)
            make.leading.equalTo(seekBar.snp.leading)
            make.trailing.equalTo(seekBar.snp.trailing)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(seekBar.snp.top).offset(-CGFloat.space12)
            make.leading.equalTo(seekBar.snp.leading)
            make.trailing.equalTo(seekBar.snp.trailing)
        }
        
        seekBar.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.leading)
            make.trailing.equalTo(settingsButton.snp.trailing)
            make.bottom.equalToSuperview().offset(-CGFloat.space24)
            make.height.equalTo(CGFloat.space2)
        }
        
        currentTimeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(totalTimeLabel.snp.leading)
            make.bottom.equalTo(totalTimeLabel.snp.bottom)
        }
        
        totalTimeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(settingsButton.snp.trailing)
            make.bottom.equalTo(seekBar.snp.top).offset(-CGFloat.space12)
        }
        
        liveButton.snp.makeConstraints { make in
            make.trailing.equalTo(settingsButton.snp.trailing)
            make.bottom.equalTo(seekBar.snp.top).offset(-CGFloat.space12)
        }
        
        liveButton.setAttributedTitle(getAttributedLiveString(isLive: true), for: .normal)
    }
    
    private func getAttributedLiveString(isLive: Bool) -> NSMutableAttributedString {
        let dotString = "\u{2022}  "
        let attributedString = NSMutableAttributedString()
        
        let dotAttributes: [NSAttributedString.Key: Any] = [
            .font: FontUtility.helveticaNeueRegular(ofSize: 20),
            .foregroundColor: isLive ? VideoPlayerColor(palette: .red).uiColor : VideoPlayerColor(palette: .pearlWhite).uiColor,
        ]

        let liveString = NSMutableAttributedString(string: dotString + "LIVE")

        let liveAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor:VideoPlayerColor(palette: .white).uiColor,
        ]

        liveString.addAttributes(liveAttributes, range: NSRange(location: dotString.count, length: "LIVE".count))

        let dotRange = NSRange(location: 0, length: dotString.count)
        liveString.addAttributes(dotAttributes, range: dotRange)
        
        attributedString.append(liveString)
        
        return attributedString
    }
}

// MARK: - Player Control Events

extension PlayerControlsView {
    private func setUpEvents() {
        // Adding targets for control events
        playPauseButton.addTarget(self, action: #selector(pausePlay), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(doForwardJump), for: .touchUpInside)
        previousVideoButton.addTarget(self, action: #selector(playPreviousVideo), for: .touchUpInside)
        nextVideoButton.addTarget(self, action: #selector(playNextVideo), for: .touchUpInside)
        seekBar.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        subtitleButton.addTarget(self, action: #selector(subtitleButtonTap), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonTap), for: .touchUpInside)
        liveButton.addTarget(self, action: #selector(seekLiveButtonTap), for: .touchUpInside)
    }
    
    // MARK: - Control Event Handlers
    
    @IBAction private func pausePlay(_: UIButton) {
        delegate?.togglePlayPause()
    }
    
    @IBAction private func doForwardJump(_: UIButton) {
        delegate?.seekForward()
    }
    
    @IBAction private func doBackwardJump(_: UIButton) {
        delegate?.seekBackward()
    }
    
    @IBAction private func playPreviousVideo(_: UIButton) {
        delegate?.playPreviousVideo()
    }
    
    @IBAction private func playNextVideo(_: UIButton) {
        delegate?.playNextVideo()
    }
    
    @IBAction private func backButtonTap(_: UIButton) {
        delegate?.goBack()
    }
    
    @IBAction private func subtitleButtonTap(_: UIButton) {
        delegate?.switchSubtitles()
    }
    
    @IBAction private func settingsButtonTap(_: UIButton) {
        delegate?.openSettings()
    }
    
    @objc private func onSliderValChanged(slider: UISlider, event: UIEvent) {
        delegate?.sliderValueChanged(slider: slider, event: event)
    }
    
    @IBAction private func seekLiveButtonTap() {
        delegate?.seekToLive()
    }
}

// MARK: - Player Control State Updation

extension PlayerControlsView {
    func disableSubtitlesButton() {
        subtitleButton.isEnabled = false
    }
    
    func unhideSettingsButton() {
        settingsButton.isHidden = false
    }
    
    func hideSettingsButton() {
        settingsButton.isHidden = true
    }
    
    func enableLiveControls() {
        liveButton.isHidden = false
        settingsButton.isHidden = true
        subtitleButton.isHidden = true
        totalTimeLabel.isHidden = true
        currentTimeLabel.isHidden = true
        forwardButton.isHidden = true
        rewindButton.isHidden = true
    }
    
    func updateLiveState(with isLive: Bool) {
        liveButton.setAttributedTitle(getAttributedLiveString(isLive: isLive), for: .normal)
        liveButton.isEnabled = !isLive
    }
}