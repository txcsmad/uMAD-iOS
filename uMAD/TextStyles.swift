import Foundation
import UIKit

enum TextStyle: String {
    case CustomButton = "CustomButton"
    
    func getUIColor() -> UIColor {
        switch self {
        case .CustomButton:
            return Color.AppTint.getUIColor()
        }
    }
    
    func getUIFont() -> UIFont {
        switch self {
        case .CustomButton:
            return UIFont.systemFontOfSize(17)
        }
    }
}
