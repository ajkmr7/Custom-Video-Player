import Foundation
import SnapKit

public enum ToastStyle {
    case success
    case error

    var color: UIColor {
        switch self {
        case .success:
            return VideoPlayerColor(palette: .green).uiColor
        case .error:
            return VideoPlayerColor(palette: .red).uiColor
        }
    }
}

public class PlayerToast: UIView {
    private let label = UILabel().configure { label in
        label.font = FontUtility.helveticaNeueMedium(ofSize: 12)
        label.textColor = VideoPlayerColor(palette: .black).uiColor
        label.textAlignment = .center
    }
    
    private var style: ToastStyle = .success

    public init(style: ToastStyle,
                message: String)
    {
        self.style = style
        label.text = message
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setUp() {
        backgroundColor = style.color
        roundCorners(cornerRadius: CGFloat.space6)
        snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(CGFloat.space48)
        }
        addSubview(label)

        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(CGFloat.space12)
            make.top.equalToSuperview().offset(CGFloat.space8)
            make.trailing.equalToSuperview().offset(-CGFloat.space8)
            make.bottom.equalToSuperview().offset(-CGFloat.space12)
        }
    }
}
