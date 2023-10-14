import UIKit

public struct VideoPlayerColor: Equatable {
    private let palette: VideoPlayerColorPalatte
    private let alpha: CGFloat

    public init(palette: VideoPlayerColorPalatte, alpha: CGFloat = 1.0) {
        self.palette = palette
        self.alpha = alpha
    }

    public var uiColor: UIColor { palette.uiColor.withAlphaComponent(alpha) }
}

public enum VideoPlayerColorPalatte: String, CaseIterable, Equatable, NameableAsset {
    case white
    case pearlWhite

    public var uiColor: UIColor { UIColor(self) }
}

