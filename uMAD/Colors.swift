import Foundation
import UIKit

enum Color: String {
    case Default = "Default"
    case White = "White"
    case AppTint = "AppTint"
    case Gray1 = "Gray1"
    case Grey2 = "Gray2"
    case Grey3 = "Gray3"
    case Grey4 = "Grey4"
    case GreyBackground = "GreyBackground"
    case Red = "Red"

    func getUIColor() -> UIColor {
        switch self {
        case .AppTint:
            return Config.tintColor
        case .Default:
            return UIColor.blackColor()
        case .Gray1:
            return UIColor.colorWithHex(0x555555)
        case .Grey2:
            return UIColor.colorWithHex(0x838383)
        case .Grey3:
            return UIColor.colorWithHex(0x808080)
        case .Grey4:
            return UIColor.colorWithHex(0x999999)
        case .White:
            return UIColor.whiteColor()
        case .GreyBackground:
            return UIColor.colorWithHex(0xeff0f4)
        case .Red:
            return UIColor.redColor()
        }
    }
}
