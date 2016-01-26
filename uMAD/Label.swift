import Foundation
import UIKit

@IBDesignable
class Label: UILabel {
    @IBInspectable var textStyleCode: String = "" {
        didSet {
            guard let textStyle = TextStyle(rawValue: textStyleCode) else {
                assertionFailure("Invalid TextStyleCode for Label")
                return
            }
            
            self.font = textStyle.getUIFont()
            self.textColor = textStyle.getUIColor()
        }
    }
}