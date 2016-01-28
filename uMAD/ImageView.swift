
import Foundation
import UIKit

@IBDesignable
class ImageView: UIImageView {
    @IBInspectable var tintColorCode: String = "" {
        didSet {
            guard let color = Color(rawValue: tintColorCode) else {
                assertionFailure("Invalid tintColorCode for ImageView")
                return
            }
            
            self.image = self.image?.imageWithRenderingMode(.AlwaysTemplate)
            self.tintColor = color.getUIColor()
        }
    }
}