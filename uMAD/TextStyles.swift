import Foundation
import UIKit

enum TextStyle: String {
    case EventTitle = "EventTitle"
    case EventInfo = "EventInfo"
    case Description = "Description"
    case AdditionalInfo = "AdditionalInfo"
    case CustomButton = "CustomButton"
    
    func getUIColor() -> UIColor {
        switch self {
        case .EventTitle:
            return Color.Default.getUIColor()
        case .EventInfo:
            return Color.AppTint.getUIColor()
        case .Description:
            return Color.Default.getUIColor()
        case .AdditionalInfo:
            return Color.Grey2.getUIColor()
        case .CustomButton:
            return Color.AppTint.getUIColor()
        }
    }
    
    func getUIFont() -> UIFont {
        switch self {
        case .EventTitle:
            return UIFont.systemFontOfSize(17, weight: UIFontWeightSemibold)
        case .EventInfo:
            return UIFont.systemFontOfSize(16)
        case .Description:
            return UIFont.systemFontOfSize(16)
        case .AdditionalInfo:
            return UIFont.systemFontOfSize(16)
        case .CustomButton:
            return UIFont.systemFontOfSize(17)
        }
    }
}