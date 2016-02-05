import UIKit
import SafariServices
import Parse

protocol LogInViewControllerDelegate: class {
	func didLogIn()
}

class LogInViewController: UITableViewController, UITextFieldDelegate {
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!

	weak var delegate: LogInViewControllerDelegate?

	let signUpFormURL = NSURL(string: "http://umad.me")!

    enum Section: Int {
        case Fields
        case SignIn
        case Actions
    }

    static func loadFromStoryboard() -> UINavigationController {
        return UIStoryboard(name: "Log-in", bundle: nil).instantiateInitialViewController() as! UINavigationController
    }

	// MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		usernameTextField.becomeFirstResponder()
		usernameTextField.delegate = self
		passwordTextField.delegate = self
	}

	// Called when the "Sign Up" button is pressed.
	private func signUp() {
		let signUpController = SFSafariViewController(URL: signUpFormURL)
		signUpController.view.tintColor = Config.tintColor
		presentViewController(signUpController, animated: true, completion: nil)
	}

    private func signIn() {
        guard let username = usernameTextField.text,
            password = passwordTextField.text else {
                return
        }

        PFUser.logInWithUsernameInBackground(username.lowercaseString, password: password) { user, error in
            if let _ = user {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.didLogIn()
                }
                return
            }

            let alert = UIAlertController(title: "Error",
                message: "\(error?.localizedDescription ?? "An error occurred")", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            alert.addAction(OKAction)
            alert.view.tintColor = Config.tintColor
            self.presentViewController(alert, animated: true, completion: nil)

        }
    }

    // MARK:- TextField Delegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == passwordTextField {
            signIn()
        } else {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }

	// MARK:- Table View Methods
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
		if section == .Actions {
			signUp()
        } else if section == .SignIn {
            signIn()
        }
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard let section = Section(rawValue: indexPath.section) else {
            return false
        }
		return section == .Actions || section == .SignIn
	}

	// MARK: - Bar Button Item IBActions

	@IBAction func cancel(sender: UIBarButtonItem) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

}
