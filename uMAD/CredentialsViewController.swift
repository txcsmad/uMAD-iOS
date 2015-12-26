import Foundation
import UIKit
import Parse

class CredentialsViewController: UIViewController {
    @IBOutlet weak var qrCode: UIImageView!
    @IBOutlet weak var checkInStatus: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    var status: UMADApplicationStatus!
    private var recheckTimer: NSTimer?
    private var previousBrightness: CGFloat!

    override func viewDidAppear(animated: Bool) {
        previousBrightness = UIScreen.mainScreen().brightness
        UIScreen.mainScreen().brightness = 0.8
    }

    override func viewWillDisappear(animated: Bool) {
        UIScreen.mainScreen().brightness = previousBrightness
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let id = User.currentUser()?.objectId else {
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        idLabel.text = id
        let rawImage = createQRForString(id)
        let scaleX = qrCode.frame.width / rawImage.extent.width
        let scaleY = qrCode.frame.height / rawImage.extent.height

        let transformedImage = rawImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))

        let image = UIImage(CIImage: transformedImage)
        qrCode.image = image
        updateCheckInStatus()
        recheckTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "updateCheckInStatus", userInfo: nil, repeats: true)

    }

    func updateCheckInStatus() {
        guard let currentUser = User.currentUser() else {
            return
        }
        status.fetchInBackgroundWithBlock { (result, error) -> Void in
            guard let status = result as? UMADApplicationStatus else {
                return
            }
            if status.arrivedAt == nil {
                self.view.backgroundColor = UIColor.redColor()
                self.checkInStatus.text = "You have not checked in"
            } else {
                self.view.backgroundColor = UIColor.greenColor()
                self.checkInStatus.text = "You are checked in"
                self.recheckTimer?.invalidate()
                self.recheckTimer = nil
            }
        }
    }

}
