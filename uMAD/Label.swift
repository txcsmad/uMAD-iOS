//
//  Label.swift
//  uMAD
//
//  Created by Matt Ruston on 1/25/16.
//  Copyright © 2016 com.MAD. All rights reserved.
//

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