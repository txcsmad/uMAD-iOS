import Foundation
import UIKit

extension UIColor {
    class func colorWithHex(hex: UInt32, alpha: CGFloat) -> UIColor {
        let r = CGFloat((hex & 0xff0000) >> 16)
        let g = CGFloat((hex & 0x00ff00) >> 8)
        let b = CGFloat(hex & 0x0000ff)
        return UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: alpha)
    }

    class func colorWithHex(hex: UInt32) -> UIColor {
        return UIColor.colorWithHex(hex, alpha: 1.0)
    }
}
