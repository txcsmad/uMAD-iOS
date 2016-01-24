import Foundation
import UIKit

class SplashInformationView: UIView {
    weak var delegate: SplashViewDelegate?
    @IBOutlet weak var signInOut: UIButton!

    static func fromNib() -> SplashInformationView! {
        guard let view = NSBundle.mainBundle().loadNibNamed("SplashInformationView", owner: nil, options: nil)[0] as? SplashInformationView else {
            print("Splash information view nib unavailable")
            return nil
        }
        return view
    }

    @IBAction func signOut() {
        delegate?.needsSignout()
        // Transition view state
    }


}