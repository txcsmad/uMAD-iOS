import Foundation
import UIKit

class SplashStatusView: UIView {
    weak var delegate: SplashViewDelegate?

    static func fromNib() -> SplashStatusView! {
        guard let view = NSBundle.mainBundle().loadNibNamed("SplashStatusView", owner: nil, options: nil)[0] as? SplashStatusView else {
            print("Splash status view nib unavailable")
            return nil
        }
        return view
    }

    @IBAction func openSite() {

    }

    @IBAction func openApplication() {
        
    }
}