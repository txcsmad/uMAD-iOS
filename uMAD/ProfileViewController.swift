import Foundation
import UIKit
import Parse

protocol ProfileViewControllerDelegate: class {
    func userDidExitProfile()
}

class ProfileViewController: UITableViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var applicationStatusLabel: UILabel!
    @IBOutlet weak var applicationStatusCell: UITableViewCell!
    @IBOutlet weak var applicationStatusSpinner: UIActivityIndicatorView!

    var delegate: ProfileViewControllerDelegate?
    override func viewDidLoad() {
        guard let currentUser = User.currentUser() else {
            // There should be a current user object at this point
            // Let's get out of here if there isn't
            delegate?.userDidExitProfile()
            return
        }
        nameLabel.text = currentUser.name

        updateApplicationStatus()
    }

    @IBAction func didTapDone(sender: UIBarButtonItem) {
        delegate?.userDidExitProfile()
    }

    @IBAction func didTapLogout(sender: UIBarButtonItem) {
        PFUser.logOutInBackground()
        delegate?.userDidExitProfile()
    }

    func updateApplicationStatus() {
        guard let currentUser = User.currentUser(),
               let currentUMAD = AppDelegate.currentUMAD else {
            // No way to know which application to check
            return
        }
        applicationStatusLabel.hidden = true
        applicationStatusSpinner.hidesWhenStopped = true
        applicationStatusSpinner.startAnimating()
        let statusQuery = UMADApplication.query()
        statusQuery?.whereKey("user", equalTo: currentUser)

        statusQuery?.whereKey("umad", equalTo: currentUMAD)
        statusQuery?.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
            self.applicationStatusSpinner.stopAnimating()

            guard let application = result?.first as? UMADApplication else {
                // No application, or query invalid
                self.applicationStatusLabel.text = "Apply to uMAD 2016"
                return
            }
            self.applicationStatusLabel.text = "uMAD 2016 Application: "
            self.applicationStatusLabel.text?.appendContentsOf(application.status)
            // TODO: We need to agree on the strings that will be used here
            if application.status == "Approved" {
                self.applicationStatusLabel.text?.appendContentsOf("! 🎉")
                self.applicationStatusCell.backgroundColor = UIColor.greenColor()
            } else {
            }
            self.applicationStatusLabel.hidden = false
        })
    }
}
