import Foundation
import UIKit
import AVFoundation
import PKHUD

class CheckInViewController: QRScanViewController {

    // MARK: - UIViewController

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        maxSimultaneousQRCodes = 1
        stopOnFirstCapture = true
    }

    // MARK: - Check-in Flow

    @IBAction func presentManualEntry() {
        let manualEntry = UIAlertController(title: "Enter User ID",
            message: "Can be found under the QR code in the \"Check-in Credential\" screen", preferredStyle: .Alert)
        manualEntry.addTextFieldWithConfigurationHandler { (field) -> Void in
            field.placeholder = "User ID"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            self.startCapturing()
        }
        let submitAction = UIAlertAction(title: "Check-in", style: .Default) { (action) -> Void in
            let textField = manualEntry.textFields!.first!
            let userId = textField.text
            self.checkIn(userId!)
        }
        manualEntry.addAction(cancelAction)
        manualEntry.addAction(submitAction)
        stopCapturing()
        presentViewController(manualEntry, animated: true, completion: nil)
    }

    func checkIn(userId: String) {
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        let query = User.query()
        query?.whereKey("objectId", equalTo: userId)
        query?.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            guard let user = results?.first as? User else {
                PKHUD.sharedHUD.contentView = PKHUDTextView(text: "No such user: \n \(userId)")
                PKHUD.sharedHUD.hide(afterDelay: 1.0)
                self.startCapturing()
                return
            }
            UMADApplicationStatus.fetchApplicationStatusWithUser(user, success: { (status) -> () in
                print("Did get application status")
                if status.arrivedAt == nil {
                    status.arrivedAt = NSDate()
                    status.saveInBackgroundWithBlock({ (success, error) -> Void in
                        PKHUD.sharedHUD.contentView = PKHUDSuccessView()
                        PKHUD.sharedHUD.hide(afterDelay: 1.0)
                        self.startCapturing()
                    })
                } else {
                    PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Already checked-in")
                    PKHUD.sharedHUD.hide(afterDelay: 1.0)
                    self.startCapturing()
                }
                }, error: { (error) -> () in
                    PKHUD.sharedHUD.contentView = PKHUDErrorView()
                    PKHUD.sharedHUD.hide(afterDelay: 1.0)
                    print(error)
                    self.startCapturing()
            })
        })
    }

    // MARK: - Handle captured

    override func didCaptureCode(string: String) {
        checkIn(string)
    }



}
