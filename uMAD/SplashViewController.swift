import Foundation
import UIKit
import Parse
import ParseUI

class SplashViewController: UIViewController, PFLogInViewControllerDelegate {
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!

    // Show to users who have a pending application
    @IBOutlet weak var statusDisplayContainer: UIView!

    // Shown to users who haven't logged in
    @IBOutlet weak var informationDisplayContainer: UIView!
    @IBOutlet weak var informationSignInOut: UIButton!

    // nil if the user hasn't applied, or the user isn't signed in yet
    private var applicationStatus: UMADApplicationStatus?

    // Centering constraints for the event emblem
    @IBOutlet weak var verticalCenterConstraint: NSLayoutConstraint?
    @IBOutlet weak var contentView: UIView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        loadCurrentConference()
        loadingSpinner.startAnimating()
        informationDisplayContainer.alpha = 0.0
        statusDisplayContainer.alpha = 0.0
    }

    override func viewWillAppear(animated: Bool) {
    }

    private func updateView() {
        loadingSpinner.stopAnimating()
        var statusAlpha: CGFloat = 0.0
        var informationAlpha: CGFloat = 1.0
        if let status = applicationStatus {
            if status.status == "Confirmed" {
                NSNotificationCenter.defaultCenter().postNotificationName("shouldPresentTabs", object: nil)
                return
            } else {
                // Display their status
                statusAlpha = 1.0
                informationAlpha = 0.0
                statusLabel.text = status.status
            }
        } else if let user = User.currentUser() {
            statusAlpha = 0.0
            informationAlpha = 1.0
            informationSignInOut.setTitle("Sign out", forState: .Normal)
            // User has account, but hasn't applied
        } else {
            statusAlpha = 0.0
            informationAlpha = 1.0
            informationSignInOut.setTitle("Sign in", forState: .Normal)
        }

        UIView.animateWithDuration(1.0, animations: {
            self.moveEmblemUp()
            self.view.layoutIfNeeded()
            }) { _ in
            UIView.animateWithDuration(1.0) {
                self.statusDisplayContainer.alpha = statusAlpha
                self.informationDisplayContainer.alpha = informationAlpha
            }
        }
    }

    // MARK:- Data

    private func loadCurrentConference() {
        guard let umadQuery = UMAD.query() else {

            return
        }
        umadQuery.orderByDescending("year")
        umadQuery.limit = 1
        umadQuery.findObjectsInBackgroundWithBlock{ results, error in
            if let resultUMADs = results as? [UMAD],
                let umad = resultUMADs.first {
                    AppDelegate.currentUMAD = umad
                    self.checkStatus()
            }
        }

    }

    private func checkStatus() {
        if let user = User.currentUser() {
            UMADApplicationStatus.fetchApplicationStatusWithUser(user) { status, error in
                self.applicationStatus = status
                self.updateView()
            }
        } else {
            updateView()
        }
    }

    // MARK:- Animation

    private func moveEmblemUp() {
        guard let oldConstraint = verticalCenterConstraint else {
            return
        }
        let newConstraint = NSLayoutConstraint(item: eventImage, attribute: .Top, relatedBy: .Equal,
            toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 50.0)
        oldConstraint.active = false
        self.contentView.addConstraint(newConstraint)
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