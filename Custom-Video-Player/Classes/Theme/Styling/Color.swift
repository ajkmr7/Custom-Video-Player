import UIKit

struct VideoPlayerColor: Equatable {
    private let palette: VideoPlayerColorPalatte
    private let alpha: CGFloat

    init(palette: VideoPlayerColorPalatte, alpha: CGFloat = 1.0) {
        self.palette = palette
        self.alpha = alpha
    }

    var uiColor: UIColor { palette.uiColor.withAlphaComponent(alpha) }
}

enum VideoPlayerColorPalatte: String, CaseIterable, Equatable, NameableAsset {
    case white
    case pearlWhite

    var uiColor: UIColor { UIColor(self) }
}

