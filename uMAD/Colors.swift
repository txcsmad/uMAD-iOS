//
//  Colors.swift
//  uMAD
//
//  Created by Matt Ruston on 1/25/16.
//  Copyright © 2016 com.MAD. All rights reserved.
//

import Foundation
import UIKit

enum Color: String {
    case Default = "Default"
    case White = "White"
    case AppTint = "AppTint"
    case Gray1 = "Gray1"
    case Grey2 = "Gray2"
    case Grey3 = "Gray3"
    
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
        case .White:
            return UIColor.whiteColor()
        }
    }
}
