import Foundation
import UIKit

enum TextStyle: String {
    case EventTitle = "EventTitle"
    case EventInfo = "EventInfo"
    case Description = "Description"
    case AdditionalInfo = "AdditionalInfo"
    case CustomButton = "CustomButton"
    case CellTitle = "CellTitle"
    case CellTime = "CellTime"
    case CellLocation = "CellLocation"
    case CellNotification = "CellNotification"

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
        case .CellTitle:
            return Color.Default.getUIColor()
        case .CellTime:
            return Color.Gray1.getUIColor()
        case .CellLocation:
            return Color.Grey3.getUIColor()
        case .CellNotification:
            return Color.Red.getUIColor()
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
        case .CellTitle:
            return UIFont.systemFontOfSize(17)
        case .CellTime:
            return UIFont.systemFontOfSize(13)
        case .CellLocation:
            return UIFont.systemFontOfSize(13)
        case .CellNotification:
            return UIFont.systemFontOfSize(17)
        }
    }
}