import Foundation
import UIKit
import Parse
import ParseUI

class SplashViewController: UIViewController, PFLogInViewControllerDelegate {
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var organizationImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!

    // Show to users who have a pending application
    @IBOutlet weak var statusDisplayContainer: UIView!

    // Shown to users who haven't logged in
    @IBOutlet weak var informationDisplayContainer: UIView!
    @IBOutlet weak var informationSignInOut: UIButton!

    // nil if the user hasn't applied, or the user isn't signed in yet
    private var applicationStatus: UMADApplicationStatus?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        loadCurrentConference()
    }

    private func updateView() {
        loadingSpinner.stopAnimating()
        // Need to animate the image up
        organizationImage.alpha = 0.0
        if let status = applicationStatus {
            if status.status == "Confirmed" {
                NSNotificationCenter.defaultCenter().postNotificationName("shouldPresentTabs", object: nil)
            } else {
                // Display their status
                statusDisplayContainer.alpha = 1.0
                statusLabel.text = status.status
            }
        } else if let user = User.currentUser() {
            statusDisplayContainer.alpha = 0.0
            informationDisplayContainer.alpha = 1.0
            informationSignInOut.setTitle("Sign out", forState: .Normal)
            // User has account, but hasn't applied
        } else {
            statusDisplayContainer.alpha = 0.0
            informationDisplayContainer.alpha = 1.0
            informationSignInOut.setTitle("Sign in", forState: .Normal)
        }
    }

    // MARK:- Data

    private func loadCurrentConference() {
        guard let umadQuery = UMAD.query() else {
            // Failure UI
            return
        }
        umadQuery.orderByDescending("year")
        umadQuery.limit = 1
        umadQuery.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            if let resultUMADs = results as? [UMAD],
                let umad = resultUMADs.first {
                    AppDelegate.currentUMAD = umad
                    self.checkStatus()
            }
        })

    }

    private func checkStatus() {
        if let user = User.currentUser() {
            UMADApplicationStatus.fetchApplicationStatusWithUser(user) { status, error in
                self.applicationStatus = status
                self.updateView()
            }
        }
    }

    // MARK:- Actions

    @IBAction func openSite() {

    }

    @IBAction func openApplication() {

    }

    @IBAction func signOut() {
        User.logOut()
        updateView()
        // Transition view state
    }

    @IBAction func signInOut() {
        if User.currentUser() != nil {
            User.logOut()
            updateView()
            return
        }

        let logInViewController = LogInViewController()
        logInViewController.delegate = self
        logInViewController.emailAsUsername = true
        let logoView = UIImageView(image: UIImage(named: "organization-logo.png"))
        logoView.contentMode = .ScaleAspectFit
        logInViewController.logInView?.logo = logoView

        presentViewController(logInViewController, animated: true, completion: nil)

    }

    // MARK:- Log In
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        checkStatus()
        dismissViewControllerAnimated(true, completion: nil)
    }

}