import UIKit

/// A struct representing a video player color with a specified palette and alpha value.
struct VideoPlayerColor: Equatable {
    private let palette: VideoPlayerColorPalatte
    private let alpha: CGFloat

    /// Initializes a `VideoPlayerColor` with a palette and an optional alpha value.
    ///
    /// - Parameters:
    ///   - palette: The color palette to use.
    ///   - alpha: The alpha value of the color (default is 1.0).
    init(palette: VideoPlayerColorPalatte, alpha: CGFloat = 1.0) {
        self.palette = palette
        self.alpha = alpha
    }

    /// The UIColor representation of the video player color.
    var uiColor: UIColor { palette.uiColor.withAlphaComponent(alpha) }
}

/// An enum representing predefined color palettes for the video player.
enum VideoPlayerColorPalatte: String, CaseIterable, Equatable, NameableAsset {
    case white
    case pearlWhite
    case black
    case red

    /// The UIColor representation of the color palette.
    var uiColor: UIColor { UIColor(self) }
}