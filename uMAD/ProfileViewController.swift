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
    private var status: UMADApplicationStatus?

    private var volunteer = false {
        didSet(oldValue) {
            tableView.reloadData()
        }
    }
    private var accepted = false {
        didSet(oldValue) {
            tableView.reloadData()
        }
    }

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

        currentUser.checkIfIsVolunteer { (volunteer) -> () in
            self.volunteer = volunteer
        }

        let displayError: String -> () = { statusText in
            self.applicationStatusLabel.text = statusText
            self.applicationStatusSpinner.stopAnimating()
            self.applicationStatusIndicator.backgroundColor = UIColor.lightGrayColor()
        }
        let displayApplyCell = {
            self.applicationStatusSpinner.stopAnimating()
            self.applicationStatusLabel.hidden = false
        }
        UMADApplication.fetchApplication({ application in
            UMADApplicationStatus.fetchApplicationStatus(application, success: { status in
                self.status = status
                self.updateApplicationStatusDisplay(status)
                self.applicationStatusSpinner.stopAnimating()
                self.applicationStatusLabel.hidden = false
            }, error: displayError)
        }, error: displayApplyCell)

    }

    @IBAction func didTapDone(sender: UIBarButtonItem) {
        delegate?.userDidExitProfile()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "check-in" {
            guard let checkInViewController = segue.destinationViewController as? CredentialsViewController else {
                return
            }
            checkInViewController.status = status
        }
    }

    // MARK: - Data

    func updateApplicationStatusDisplay(status: UMADApplicationStatus) {
        applicationStatusLabel.text = "Status: "
        applicationStatusLabel.text?.appendContentsOf(status.status)

        let indicatorColor: UIColor
        // TODO: We need to agree on the strings that will be used here
        switch status.status {
        case "Accepted":
            self.applicationStatusLabel.text?.appendContentsOf("! 🎉")
            indicatorColor = UIColor(red: 0.76, green: 0.92, blue: 0.25, alpha: 1.0)
            accepted = true
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
        case 3:
            PFUser.logOutInBackground()
            delegate?.userDidExitProfile()
            break
        default:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let original = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 1: fallthrough
            case 2:
                return accepted ? original : 0
            default:
                return original
            }
        case 2:
            return original
            //return volunteer ? original: 0
        default:
            return original
        }
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let original = super.tableView(tableView, heightForHeaderInSection: section)
        if section == 2 {
            return volunteer ? original : 0
        }
        return original
    }
}
