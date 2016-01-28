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
    private var status: UMADApplicationStatus?

    enum Section: Int {
        case Name
        case Volunteer
        case Actions

        static let allValues = [Section.Name, .Volunteer, .Actions]
    }

    enum NameRow: Int {
        case Name
        case Credential
    }

    private var volunteer = false {
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
        
        currentUser.checkIfIsVolunteer { (volunteer) -> () in
            self.volunteer = volunteer
        }
        UMADApplicationStatus.fetchApplicationStatusWithUser(currentUser) { status, error in
            self.status = status
        }
    }

    @IBAction func didTapDone(sender: UIBarButtonItem) {
        delegate?.userDidExitProfile()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "check-in" {
            guard let checkInViewController = segue.destinationViewController as? CredentialsViewController,
                let status = status else {
                return
            }
            checkInViewController.status = status
        }
    }

    // MARK: - Data


    // MARK: - UITableViewController
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        switch section {
        case .Actions:
            PFUser.logOutInBackground()
            delegate?.userDidExitProfile()
            NSNotificationCenter.defaultCenter().postNotificationName("shouldPresentSplash", object: nil)
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
