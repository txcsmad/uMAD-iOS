import Foundation
import UIKit
import Parse

class CredentialsViewController: UIViewController {
    
    @IBOutlet weak var qrCode: UIImageView!
    @IBOutlet weak var checkInStatus: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checkedInContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var status: UMADApplicationStatus!
    private var recheckTimer: NSTimer?
    private var previousBrightness: CGFloat!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        previousBrightness = UIScreen.mainScreen().brightness
        UIScreen.mainScreen().brightness = 0.8
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIScreen.mainScreen().brightness = previousBrightness
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = User.currentUser(),
            id = user.objectId else {
            dismissViewControllerAnimated(true, completion: nil)
            return
        }

        checkingIndicator.hidesWhenStopped = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.colorWithHex(0xffc22f).CGColor, UIColor.colorWithHex(0xffa61e).CGColor]
        gradientLayer.frame = view.frame
        view.layer.insertSublayer(gradientLayer, atIndex: 0)

        checkedInContainerView.layer.cornerRadius = 8.0
        containerView.layer.cornerRadius = 8.0
        
        idLabel.text = id
        nameLabel.text = user.name
        let rawImage = createQRForString(id)
        let scaleX = qrCode.frame.width / rawImage.extent.width
        let scaleY = qrCode.frame.height / rawImage.extent.height

        let transformedImage = rawImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))

        let image = UIImage(CIImage: transformedImage)
        qrCode.image = image
        updateCheckInStatus()
    }


    func updateCheckInStatus() {
        guard let _ = User.currentUser() else {
            return
        }
        
        checkInStatus.hidden = true
        checkingIndicator.startAnimating()
        status.fetchInBackgroundWithBlock { result, error in
            guard let status = result as? UMADApplicationStatus else {
                return
            }
            if status.arrivedAt == nil {
                self.checkInStatus.text = "Not checked-in"
            } else {
                self.checkInStatus.text = "✅ Checked-in"
                self.recheckTimer?.invalidate()
                self.recheckTimer = nil
            }
            self.checkingIndicator.stopAnimating()
            self.checkInStatus.hidden = false
        }
    }

}
