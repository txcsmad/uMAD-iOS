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
    private var status: UMADApplicationStatus?

    enum Section: Int {
        case Name
        case Application
        case Volunteer
        case Actions
    }

    enum ApplicationRow: Int {
        case Status
        case ApplyLink
        case Credential
    }

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
    private var applied = false {
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
            // We've got an application. Take note.
            self.applied = true
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
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        switch section {
        case .Application:
            if indexPath.row == 1 {
            let applyToUMADURL = NSURL(string: "http://umad.me")!
            let webView = SFSafariViewController(URL: applyToUMADURL)
            navigationController?.pushViewController(webView, animated: true)
            }
            break
        case .Actions:
            PFUser.logOutInBackground()
            delegate?.userDidExitProfile()
            break
        default:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    // MARK:- UITableViewDelegate

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let original = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        guard let section = Section(rawValue: indexPath.section) else {
            return 0.0
        }
        switch section {

        case .Application:
            guard let row = ApplicationRow(rawValue: indexPath.row) else {
                return 0.0
            }
            switch row {
            // Decide which cells to show based on what we know about the user
            case .Status:
                return applied ? original : 0
            case .ApplyLink:
                return applied ? 0 : original
            case .Credential:
                return accepted ? original : 0
            }
        case .Volunteer:
            return volunteer ? original: 0
        default:
            return original
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let original = super.tableView(tableView, titleForHeaderInSection: section)
        guard let section = Section(rawValue: section) else {
            return nil
        }
        if section == .Volunteer {
            return volunteer ? original : ""
        }
        return original
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let original = super.tableView(tableView, heightForHeaderInSection: section)
        guard let section = Section(rawValue: section) else {
            return 0.0
        }
        if section == .Volunteer {
            return volunteer ? original : 0
        }
        return original
    }
}
