import Foundation
import UIKit
import SnapKit

enum CustomButtonStyle: String {
    case RoundedRect = "RoundedRect"
}

@IBDesignable
class CustomButton: UIButton {
    private var backgroundColorByState = [UInt : UIColor]()
    private var tintColorByState = [UInt : UIColor]()
    private var borderColorByState = [UInt : CGColor]()
    
    //Image used with certain button styles
    @IBInspectable var customImage: UIImage = UIImage() {
        didSet {
            customImage = customImage.imageWithRenderingMode(.AlwaysTemplate)
            customImageView.image = customImage
        }
    }
    
    @IBInspectable var customImageHighlighted: UIImage = UIImage() {
        didSet {
            customImageHighlighted = customImageHighlighted.imageWithRenderingMode(.AlwaysTemplate)
        }
    }
    private let customImageView = UIImageView()
    private let customImageHeight: CGFloat = 24.0
    
    @IBInspectable var styleCode: String = "" {
        didSet {
            self.setStyle(styleCode)
        }
    }
    
    override var selected: Bool {
        didSet {
            setValues()
        }
    }
    
    override var highlighted: Bool {
        didSet {
            setValues()
        }
    }
    
    override var enabled: Bool {
        didSet {
            setValues()
        }
    }
    
    private func setValues() {
        self.tintColor = self.tintColorForCurrentState()
        self.backgroundColor = self.backgroundColorForCurrentState()
        self.layer.borderColor = self.borderColorForCurrentState()
        
        if selected || highlighted {
            customImageView.image = customImageHighlighted
            customImageView.tintColor = Color.White.getUIColor()
        } else {
            customImageView.image = customImage
            customImageView.tintColor = Color.AppTint.getUIColor()
        }
    }

    private func setStyle(styleCode: String) {
        if styleCode == "" {
            return
        }
        
        guard let buttonStyle = CustomButtonStyle(rawValue: styleCode) else {
            assertionFailure("Invalid styleCode for CustomButton")
            return
        }
        
        switch buttonStyle {
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

    override func tintColorDidChange() {
        super.tintColorDidChange()
        setStyle(styleCode)
    }
}


//MARK: - Button Types

extension CustomButton {
    //NOTE: Make sure button type is custom, or else title alpha will change
    func applyRoundedRectStyle() {
        self.setBackgroundColor(Color.White.getUIColor(), state: .Normal)
        self.setBackgroundColor(tintColor.colorWithAlphaComponent(0.5), state: .Highlighted)
        self.setBackgroundColor(tintColor.colorWithAlphaComponent(0.5), state: UIControlState.init(rawValue: 5))
        self.setBackgroundColor(tintColor, state: .Selected)
        
        self.setTitleColor(tintColor, forState: .Normal)
        self.setTitleColor(Color.White.getUIColor(), forState: .Highlighted)
        self.setTitleColor(Color.White.getUIColor(), forState: UIControlState.init(rawValue: 5))
        self.setTitleColor(Color.White.getUIColor(), forState: .Selected)
        
        self.layer.cornerRadius = self.bounds.height / 2.0
        self.layer.borderColor = tintColor.CGColor
        self.layer.borderWidth = 1
        
        customImageView.tintColor = tintColor
        customImageView.contentMode = .ScaleAspectFit
        self.addSubview(customImageView)
        
        customImageView.snp_makeConstraints { (make) -> Void in
            make.height.width.equalTo(customImageHeight)
            make.leading.equalTo(self).offset(22)
            make.centerY.equalTo(self)
        }
        
        if let title = self.titleLabel {
            title.snp_remakeConstraints(closure: { (make) -> Void in
                make.centerY.equalTo(self)
                make.leading.equalTo(customImageView.snp_trailing).offset(7)
            })
            
            title.font = TextStyle.CustomButton.getUIFont()
        }
    }
}
