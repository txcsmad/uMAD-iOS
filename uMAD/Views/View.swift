
import Foundation
import UIKit

@IBDesignable
class View: UIView {
    @IBInspectable var backgroundColorCode: String = "" {
        didSet {
            guard let color = Color(rawValue: backgroundColorCode) else {
                assertionFailure("Invalid backgroundColorCode for View")
                return
            }

            self.backgroundColor = color.getUIColor()
            self.layoutIfNeeded()
        }
    }
}
