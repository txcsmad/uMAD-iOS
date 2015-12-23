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
    @IBOutlet weak var applicationStatusIndicator: UIView!
    @IBOutlet weak var applicationStatusSpinner: UIActivityIndicatorView!

    var delegate: ProfileViewControllerDelegate?
    override func viewDidLoad() {
        guard let currentUser = User.currentUser() else {
            // There should be a current user object at this point
            // Let's get out of here if there isn't
            delegate?.userDidExitProfile()
            return
        }
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2.0
        nameLabel.text = currentUser.name
        applicationStatusIndicator.layer.cornerRadius = applicationStatusIndicator.frame.width / 2.0
        updateApplicationStatus()
    }

    @IBAction func didTapDone(sender: UIBarButtonItem) {
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

            let indicatorColor: UIColor
            // TODO: We need to agree on the strings that will be used here
            switch application.status {
                case "Accepted":
                    self.applicationStatusLabel.text?.appendContentsOf("! 🎉")
                    indicatorColor = UIColor(red: 0.76, green: 0.92, blue: 0.25, alpha: 1.0)
                    break
                case "Pending":
                    indicatorColor = UIColor.lightGrayColor()
                    break
                case "Waitlisted":
                    indicatorColor = UIColor.yellowColor()
                default:
                    indicatorColor = UIColor.grayColor()
            }
            self.applicationStatusIndicator.backgroundColor = indicatorColor
            self.applicationStatusLabel.hidden = false
        })
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 2:
            PFUser.logOutInBackground()
            delegate?.userDidExitProfile()
            break
        default:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}
