import Foundation
import SafariServices
import ParseUI

class LogInViewController: PFLogInViewController, SFSafariViewControllerDelegate {
    let signUpFormURL = NSURL(string: "http://www.cs.utexas.edu/users/mad/")!

    /**
     Called when the signup button is pressed.
     */
    func _signupAction() {
        let signUpController = SFSafariViewController(URL: signUpFormURL)
        signUpController.delegate = self
        presentViewController(signUpController, animated: true, completion: nil)
    }

    func safariViewControllerDidFinish(controller: SFSafariViewController) {

    }
}
