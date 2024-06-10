import UIKit

/// A utility class for managing custom font styles.
class FontUtility {
    
    /// Returns a font with the HelveticaNeue-Light style at the specified size.
    ///
    /// - Parameter size: The size of the font.
    /// - Returns: A UIFont object with the HelveticaNeue-Light style.
    static func helveticaNeueLight(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
    }
    
    /// Returns a font with the HelveticaNeue-Regular style at the specified size.
    ///
    /// - Parameter size: The size of the font.
    /// - Returns: A UIFont object with the HelveticaNeue-Regular style.
    static func helveticaNeueRegular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    /// Returns a font with the HelveticaNeue-Medium style at the specified size.
    ///
    /// - Parameter size: The size of the font.
    /// - Returns: A UIFont object with the HelveticaNeue-Medium style.
    static func helveticaNeueMedium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
}
