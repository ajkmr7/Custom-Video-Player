import UIKit

class FontUtility {
    static func helveticaNeueLight(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
    }
    
    static func helveticaNeueRegular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    static func helveticaNeueMedium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
}

