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

    var delegate: ProfileViewControllerDelegate?
    override func viewDidLoad() {
        nameLabel.text = User.currentUser()?.name
    }

    @IBAction func didTapDone(sender: UIBarButtonItem) {
        delegate?.userDidExitProfile()
    }

    @IBAction func didTapLogout(sender: UIBarButtonItem) {
        PFUser.logOutInBackground()
        delegate?.userDidExitProfile()
    }
}
