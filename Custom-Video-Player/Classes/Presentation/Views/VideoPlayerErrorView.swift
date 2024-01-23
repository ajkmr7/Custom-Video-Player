import SnapKit

class VideoPlayerErrorView: UIView {
    private let errorTitle = UILabel().configure {
        $0.numberOfLines = 0
        $0.font = FontUtility.helveticaNeueMedium(ofSize: 20)
        $0.textColor = VideoPlayerColor(palette: .white).uiColor
        $0.lineBreakMode = .byWordWrapping
    }

    private let backButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.backButton.uiImage, for: .normal)
    }
    
    private let dynamicSpacing: CGFloat = UIScreen.main.bounds.height * 0.055

    @objc private let onBackButtonClicked: () -> Void

    init(title: String, onBackButtonClicked: @escaping () -> Void) {
        errorTitle.text = title
        self.onBackButtonClicked = onBackButtonClicked
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(backButton)
        addSubview(errorTitle)

        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.space24)
            make.leading.equalToSuperview().offset(dynamicSpacing)
        }
        
        errorTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        backButton.addTarget(self, action: #selector(onBackButtonTap), for: .touchUpInside)
    }

    @objc private func onBackButtonTap() {
        onBackButtonClicked()
    }
}
