import Foundation
import UIKit

class SplashStatusView: UIView {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    weak var delegate: SplashViewDelegate?

    static func fromNib() -> SplashStatusView! {
        guard let view = NSBundle.mainBundle().loadNibNamed("SplashStatusView", owner: nil, options: nil)[0] as? SplashStatusView else {
            print("Splash status view nib unavailable")
            return nil
        }
        return view
    }

    @IBAction func openSite() {
        delegate?.openSite()
    }

    @IBAction func signOut() {
        delegate?.needsSignout()
    }
}
