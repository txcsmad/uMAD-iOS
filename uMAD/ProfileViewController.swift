import Foundation
import UIKit
import Parse
import SafariServices

protocol ProfileViewControllerDelegate: class {
    func userDidExitProfile()
}

class ProfileViewController: UITableViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var applicationStatusLabel: UILabel!
    @IBOutlet weak var applicationStatusIndicator: UIView!
    @IBOutlet weak var applicationStatusSpinner: UIActivityIndicatorView!
    @IBOutlet weak var applicationStatusCell: UITableViewCell!
    @IBOutlet weak var applyToUMADCell: UITableViewCell!

    weak var delegate: ProfileViewControllerDelegate?
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
        applicationStatusLabel.hidden = true
        applicationStatusSpinner.hidesWhenStopped = true
        applicationStatusSpinner.startAnimating()
        applyToUMADCell.hidden = true

        let displayError: String -> () = { statusText in
            self.applicationStatusLabel.text = statusText
            self.applicationStatusSpinner.stopAnimating()
            self.applicationStatusLabel.hidden = false
            self.applicationStatusIndicator.backgroundColor = UIColor.lightGrayColor()
        }
        let displayApplyCell = {
            self.applicationStatusSpinner.stopAnimating()
            self.applicationStatusLabel.hidden = false
            self.applyToUMADCell.hidden = false
            self.applicationStatusCell.hidden = true
        }
        fetchApplication({ application in
            self.fetchApplicationStatus(application, success: { status in
                self.updateApplicationStatusDisplay(status)
                self.applicationStatusSpinner.stopAnimating()
                self.applicationStatusLabel.hidden = false
            }, error: displayError)
        }, error: displayApplyCell)

    }

    @IBAction func didTapDone(sender: UIBarButtonItem) {
        delegate?.userDidExitProfile()
    }

    // MARK: - Data

    func fetchApplication(success: (UMADApplication) -> (), error: () -> ()) {
        guard let currentUser = User.currentUser(),
            let currentUMAD = AppDelegate.currentUMAD else {
                error()
                return
        }

        let statusQuery = UMADApplication.query()
        statusQuery?.whereKey("user", equalTo: currentUser)
        statusQuery?.whereKey("umad", equalTo: currentUMAD)
        statusQuery?.findObjectsInBackgroundWithBlock({ (result, err) -> Void in
            guard let application = result?.first as? UMADApplication else {
                // No application, or query invalid
                error()
                return
            }
            guard result?.count == 1 else {
                // More than one application
                error()
                return
            }
            success(application)
        })
    }

    func fetchApplicationStatus(application: UMADApplication, success: (UMADApplicationStatus) -> (), error: (String) -> ()) {
        let query = UMADApplicationStatus.query()
        query?.whereKey("application", equalTo: application)
        query?.findObjectsInBackgroundWithBlock({ (result, err) -> Void in
            guard let status = result?.first as? UMADApplicationStatus else {
                // No status. This is a serious error
                print("No status for application!")
                error("Something went wrong")
                return
            }

            success(status)
        })
    }

    func updateApplicationStatusDisplay(status: UMADApplicationStatus) {
        self.applicationStatusLabel.text = "Status: "
        self.applicationStatusLabel.text?.appendContentsOf(status.status)

        let indicatorColor: UIColor
        // TODO: We need to agree on the strings that will be used here
        switch status.status {
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
    }


    // MARK: - UITableViewController
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            if indexPath.row == 1 {
            let applyToUMADURL = NSURL(string: "http://umad.me")!
            let webView = SFSafariViewController(URL: applyToUMADURL)
            navigationController?.pushViewController(webView, animated: true)
            }
            break
        case 2:
            PFUser.logOutInBackground()
            delegate?.userDidExitProfile()
            break
        default:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}
