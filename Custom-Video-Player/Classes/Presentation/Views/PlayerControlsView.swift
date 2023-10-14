import MediaPlayer
import UIKit
import SnapKit

@objc protocol PlayerControlsViewDelegate {
    func seekForward()
    func seekBackward()
    func togglePlayPause()
    func goBack()
    func sliderValueChanged(slider: UISlider, event: UIEvent)
    func switchSubtitles()
    func openSettings()
}

// MARK: - Player Controls

class PlayerControlsView: UIView {
    weak var delegate: PlayerControlsViewDelegate?
    
    // MARK: - Controls on Top
    
    private let backButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.backButton.uiImage, for: .normal)
    }
    
    private let subtitleButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.subtitlesButton.uiImage, for: .normal)
    }

    private let moreButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.moreButton.uiImage, for: .normal)
    }
    
    // MARK: - Controls on Middle
    
    private let rewindButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.rewindButton.uiImage, for: .normal)
    }

    private let playPauseButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.pauseButton.uiImage, for: .normal)
    }

    private let forwardButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.forwardButton.uiImage, for: .normal)
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
            seekBar.minimumTrackTintColor = VideoPlayerColor(palette: .white).uiColor
            seekBar.minimumValue = 0
            seekBar.setThumbImage(nil, for: .normal)
            let thumbSize = CGSize(width: CGFloat.space12, height: CGFloat.space12)
            let thumbImage = UIGraphicsImageRenderer(size: thumbSize).image { _ in
                VideoPlayerColor(palette: .white).uiColor.setFill()
                UIBezierPath(ovalIn: CGRect(origin: .zero, size: thumbSize)).fill()
            }
            seekBar.setThumbImage(thumbImage, for: .highlighted)
        }

    private let currentTimeLabel = UILabel().configure {
        $0.text = "00:00"
        $0.font = FontUtility.helveticaNeueLight(ofSize: 14)
        $0.textColor = VideoPlayerColor(palette: .white).uiColor
    }

    private let totalTimeLabel = UILabel().configure {
        $0.text = "/ 00:00"
        $0.font = FontUtility.helveticaNeueLight(ofSize: 14)
        $0.textColor = VideoPlayerColor(palette: .white).uiColor
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
        addSubview(backButton)
        addSubview(subtitleButton)
        addSubview(moreButton)
        
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.space24)
            make.leading.equalToSuperview().offset(dynamicSpacing)
        }
        
        subtitleButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.top)
            make.trailing.equalTo(moreButton.snp.leading).offset(-CGFloat.space8)
        }
        
        moreButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.top)
            make.trailing.equalToSuperview().offset(-dynamicSpacing)
        }
        
        addSubview(rewindButton)
        addSubview(playPauseButton)
        addSubview(forwardButton)
        
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
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(seekBar)
        addSubview(currentTimeLabel)
        addSubview(totalTimeLabel)
        
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
            make.trailing.equalTo(moreButton.snp.trailing)
            make.bottom.equalToSuperview().offset(-CGFloat.space24)
            make.height.equalTo(CGFloat.space2)
        }
        
        currentTimeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(totalTimeLabel.snp.leading)
            make.bottom.equalTo(totalTimeLabel.snp.bottom)
        }
        
        totalTimeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(moreButton.snp.trailing)
            make.bottom.equalTo(seekBar.snp.top).offset(-CGFloat.space12)
        }
    }
}

// MARK: - Player Control Events

extension PlayerControlsView {
    private func setUpEvents() {
        playPauseButton.addTarget(self, action: #selector(pausePlay), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(doForwardJump), for: .touchUpInside)
        rewindButton.addTarget(self, action: #selector(doBackwardJump), for: .touchUpInside)
        seekBar.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        subtitleButton.addTarget(self, action: #selector(subtitleButtonTap), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(moreButtonTap), for: .touchUpInside)
    }

    @IBAction private func pausePlay(_: UIButton) {
        delegate?.togglePlayPause()
    }

    @IBAction private func doForwardJump(_: UIButton) {
        delegate?.seekForward()
    }

    @IBAction private func doBackwardJump(_: UIButton) {
        delegate?.seekBackward()
    }

    @IBAction private func backButtonTap(_: UIButton) {
        delegate?.goBack()
    }

    @IBAction private func subtitleButtonTap(_: UIButton) {
        delegate?.switchSubtitles()
    }

    @IBAction private func moreButtonTap(_: UIButton) {
        delegate?.openSettings()
    }

    @objc private func onSliderValChanged(slider: UISlider, event: UIEvent) {
        delegate?.sliderValueChanged(slider: slider, event: event)
    }
}