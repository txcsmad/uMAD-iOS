import Foundation
import UIKit
import SnapKit

enum CustomButtonStyle: String {
    case RoundedRect = "RoundedRect"
    case RoundedRectDarkBackground = "RoundedRectDark"
}

@IBDesignable
class CustomButton: UIButton {
    private var backgroundColorByState = [UInt : UIColor]()
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
            setStyle(styleCode)
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
        backgroundColor = backgroundColorForCurrentState()
        layer.borderColor = borderColorForCurrentState()

        if selected || highlighted {
            customImageView.image = customImageHighlighted
            customImageView.tintColor = Color.White.getUIColor()
        } else {
            customImageView.image = customImage
            customImageView.tintColor = tintColor
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
            applyRoundedRectStyle()
            break
        case .RoundedRectDarkBackground:
            applyRoundedRectDarkBackgroundStyle()
        }
    }

    //MARK:-

    func setBackgroundColor(backgroundColor: UIColor, state: UIControlState) -> Void {
        let key = state.rawValue
        backgroundColorByState[key] = backgroundColor
    }

    func setBorderColor(borderColor: UIColor, state: UIControlState) {
        let key = state.rawValue
        borderColorByState[key] = borderColor.CGColor

        if state == .Normal {
            layer.borderColor = borderColor.CGColor
        }
    }

    func backgroundColorForState(state: UIControlState) -> UIColor? {
        let key = state.rawValue
        var color = backgroundColorByState[key]

        if color == nil {
            let normalKey = UIControlState.Normal.rawValue
            color = backgroundColorByState[normalKey]
        }

        if color == nil {
            color = backgroundColor
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
            color = layer.borderColor
        }

        return color
    }

    private func backgroundColorForCurrentState() -> UIColor? {
        let backgroundColor = backgroundColorForState(state)
        return backgroundColor
    }

    private func borderColorForCurrentState() -> CGColor? {
        let borderColor = borderColorForState(state)
        return borderColor
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        setStyle(styleCode)
        setValues()
    }
}


//MARK: - Button Types

extension CustomButton {
    //NOTE: Make sure button type is custom, or else title alpha will change
    func applyRoundedRectStyle() {
        setBackgroundColor(Color.White.getUIColor(), state: .Normal)
        setBackgroundColor(tintColor.colorWithAlphaComponent(0.5), state: .Highlighted)
        setBackgroundColor(tintColor.colorWithAlphaComponent(0.5), state: UIControlState.init(rawValue: 5))
        setBackgroundColor(tintColor, state: .Selected)

        setTitleColor(tintColor, forState: .Normal)
        setTitleColor(Color.White.getUIColor(), forState: .Highlighted)
        setTitleColor(Color.White.getUIColor(), forState: UIControlState.init(rawValue: 5))
        setTitleColor(Color.White.getUIColor(), forState: .Selected)

        layer.cornerRadius = bounds.height / 2.0
        layer.borderColor = tintColor.CGColor
        layer.borderWidth = 1

        customImageView.tintColor = tintColor
        customImageView.contentMode = .ScaleAspectFit
        addSubview(customImageView)

        customImageView.snp_makeConstraints { (make) -> Void in
            make.height.width.equalTo(customImageHeight)
            make.leading.equalTo(self).offset(22)
            make.centerY.equalTo(self)
        }

        if let title = titleLabel {
            title.snp_remakeConstraints(closure: { (make) -> Void in
                make.centerY.equalTo(self)
                make.leading.equalTo(customImageView.snp_trailing).offset(7)
            })

            title.font = TextStyle.CustomButton.getUIFont()
        }
    }

    func applyRoundedRectDarkBackgroundStyle() {

    }
}
