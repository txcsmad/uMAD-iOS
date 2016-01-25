//
//  TextStyles.swift
//  uMAD
//
//  Created by Matt Ruston on 1/25/16.
//  Copyright © 2016 com.MAD. All rights reserved.
//

import Foundation
import UIKit

enum TextStyle: String {
    case EventTitle = "EventTitle"
    case EventInfo = "EventInfo"
    case Description = "Description"
    case AdditionalInfo = "AdditionalInfo"
    
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
        }
    }
}