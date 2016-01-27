//
//  Log-InViewController.swift
//  uMAD
//
//  Created by Mark Malstrom on 1/26/16.
//  Copyright © 2016 com.MAD. All rights reserved.
//

import UIKit
import SafariServices
import Parse

protocol LogInViewControllerDelegate: class {
	func logInViewController()
}

class LogInViewController: UITableViewController, UITextFieldDelegate {
	// MARK: -
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var signInButton: UIBarButtonItem!

	weak var delegate: LogInViewControllerDelegate?

	let signUpFormURL = NSURL(string: "http://www.cs.utexas.edu/users/mad/")!

	// MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
		signInButton.enabled = false
		usernameTextField.becomeFirstResponder()
		usernameTextField.delegate = self
		passwordTextField.delegate = self
	}

	// Called when the "Sign Up" button is pressed.
	func signUp() {
		let signUpController = SFSafariViewController(URL: signUpFormURL)
		signUpController.view.tintColor = Config.tintColor
		presentViewController(signUpController, animated: true, completion: nil)
	}

	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		signInButton.enabled = !passwordTextField.text!.isEmpty && !usernameTextField.text!.isEmpty
		return true
	}

	// MARK: - Table View Methods
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath == NSIndexPath(forRow: 1, inSection: 1) {
			signUp()
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return indexPath.section == 1 && indexPath.row < 2
	}

	// MARK: - Bar Button Item IBActions

	@IBAction func cancel(sender: UIBarButtonItem) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func signIn(sender: UIBarButtonItem) {
		let username: String! = usernameTextField.text
		let password: String! = passwordTextField.text

		PFUser.logInWithUsernameInBackground(username, password: password) { (user, error) -> Void in
			if let _ = user {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.delegate?.logInViewController()
				})
			} else {
				let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
				let OKAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
				alert.addAction(OKAction)
				alert.view.tintColor = Config.tintColor
				self.presentViewController(alert, animated: true, completion: nil)
			}
		}
	}
}
