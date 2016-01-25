//
//  CustomButton.swift
//  uMAD
//
//  Created by Matt Ruston on 1/25/16.
//  Copyright © 2016 com.MAD. All rights reserved.
//

import Foundation
import UIKit

enum CustomButtonStyle: String {
    case RoundedRect = "RoundedRect"
}

@IBDesignable
class CustomButton: UIButton {
    private var backgroundColorByState = [UInt : UIColor]()
    private var tintColorByState = [UInt : UIColor]()
    private var borderColorByState = [UInt : CGColor]()
    
    @IBInspectable var styleCode: String = "" {
        didSet {
            guard let buttonStyle = CustomButtonStyle(rawValue: styleCode) else {
                assertionFailure("Invalid styleCode for CustomButton")
                return
            }
            
            self.setStyle(buttonStyle)
        }
    }
    
    //Image used with certain button styles
    @IBInspectable var customImage: UIImage = UIImage()
    
    private func setStyle(style: CustomButtonStyle) {
        switch style {
        case .RoundedRect:
            self.applyRoundedRectStyle()
        }
    }
    
    func setTintColor(tintColor: UIColor, state: UIControlState) -> Void {
        let key = state.rawValue
        tintColorByState[key] = tintColor
        
        if state == .Normal {
            self.tintColor = tintColor
        }
    }
    
    func setBackgroundColor(backgroundColor: UIColor, state: UIControlState) -> Void {
        let key = state.rawValue
        backgroundColorByState[key] = backgroundColor
        
        if state == .Normal {
            self.backgroundColor = backgroundColor
        }
    }
    
    func setBorderColor(borderColor: UIColor, state: UIControlState) {
        let key = state.rawValue
        borderColorByState[key] = borderColor.CGColor
        
        if state == .Normal {
            self.layer.borderColor = borderColor.CGColor
        }
    }
    
    override var selected: Bool {
        didSet {
            self.tintColor = self.tintColorForCurrentState()
            self.backgroundColor = self.backgroundColorForCurrentState()
            self.layer.borderColor = self.borderColorForCurrentState()
        }
    }
    
    override var highlighted: Bool {
        didSet {
            self.tintColor = self.tintColorForCurrentState()
            self.backgroundColor = self.backgroundColorForCurrentState()
            self.layer.borderColor = self.borderColorForCurrentState()
        }
    }
    
    override var enabled: Bool {
        didSet {
            self.tintColor = self.tintColorForCurrentState()
            self.backgroundColor = self.backgroundColorForCurrentState()
            self.layer.borderColor = self.borderColorForCurrentState()
        }
    }
    
    func tintColorForState(state: UIControlState) -> UIColor? {
        let key = state.rawValue
        var color = tintColorByState[key]
        
        if color == nil {
            let normalKey = UIControlState.Normal.rawValue
            color = tintColorByState[normalKey]
        }
        
        if color == nil {
            color = self.tintColor
        }
        
        return color
    }
    
    func backgroundColorForState(state: UIControlState) -> UIColor? {
        let key = state.rawValue
        var color = backgroundColorByState[key]
        
        if color == nil {
            let normalKey = UIControlState.Normal.rawValue
            color = backgroundColorByState[normalKey]
        }
        
        if color == nil {
            color = self.backgroundColor
        }
        
        return color
    }
    
    func borderColorForState(state: UIControlState) -> CGColor? {
        let key = state.rawValue
        var color = borderColorByState[key]
        
        if color == nil {
            let normalKey = UIControlState.Normal.rawValue
            color = borderColorByState[normalKey]
        }
        
        if color == nil {
            color = self.layer.borderColor
        }
        
        return color
    }
    
    private func backgroundColorForCurrentState() -> UIColor? {
        let backgroundColor = self.backgroundColorForState(self.state)
        return backgroundColor
    }
    
    private func tintColorForCurrentState() -> UIColor? {
        let tintColor = self.tintColorForState(self.state)
        return tintColor
    }
    
    private func borderColorForCurrentState() -> CGColor? {
        let borderColor = self.borderColorForState(self.state)
        return borderColor
    }
}


//MARK: - Button Types

extension CustomButton {
    func applyRoundedRectStyle() {
        self.setBackgroundColor(Color.White.getUIColor(), state: .Normal)
        self.setBackgroundColor(Color.AppTint.getUIColor(), state: .Highlighted)
        
        self.layer.cornerRadius = self.bounds.height / 2.0
        self.layer.borderColor = Color.AppTint.getUIColor().CGColor
        self.layer.borderWidth = 1
        
        let imageView = UIImageView(image: customImage)
        
    }
}
