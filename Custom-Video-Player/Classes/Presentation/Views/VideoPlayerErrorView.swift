import SnapKit
import UIKit

class VideoPlayerErrorView: UIView {
    // MARK: - View Components

    private let errorTitle = UILabel().configure {
        $0.numberOfLines = 0
        $0.font = FontUtility.helveticaNeueMedium(ofSize: 20)
        $0.textColor = VideoPlayerColor(palette: .white).uiColor
        $0.lineBreakMode = .byWordWrapping
    }

    private let backButton = UIButton().configure {
        $0.setImage(VideoPlayerImage.backButton.uiImage, for: .normal)
    }
    
    /// Dynamic spacing based on screen height.
    private let dynamicSpacing: CGFloat = UIScreen.main.bounds.height * 0.055

    // MARK: - Callback
    @objc private let onBackButtonClicked: () -> Void

    // MARK: - Initialization
    
    /// Initializes the error view with a title and callback for the back button.
    ///
    /// - Parameters:
    ///   - title: The title to be displayed as the error message.
    ///   - onBackButtonClicked: A closure to be executed when the back button is tapped.
    init(title: String, onBackButtonClicked: @escaping () -> Void) {
        errorTitle.text = title
        self.onBackButtonClicked = onBackButtonClicked
        super.init(frame: .zero)
        setupView()
    }

    /// Unsupported initializer from Interface Builder.
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup
    
    /// Sets up the appearance and layout of the error view's subviews.
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

    // MARK: - Action Handling
    
    /// Handles the action when the back button is tapped.
    @objc private func onBackButtonTap() {
        onBackButtonClicked()
    }
}
