import Foundation
import UIKit
import Parse
import ParseUI
import SafariServices

protocol SplashViewDelegate: class {
    func needsLogin()
    func needsSignout()
    func openApplication()
    func openSite()
}


class SplashViewController: UIViewController, LogInViewControllerDelegate, SplashViewDelegate {
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var eventImage: UIImageView!

    // Centering constraints for the event emblem
    @IBOutlet weak var eventImageCenterYConstraint: NSLayoutConstraint?

    // Show to users who have a pending application
    var statusDisplayContainer: SplashStatusView!

    // Shown to users who haven't logged in
    var informationDisplayContainer: SplashInformationView!

    private var applicationStatus: UMADApplicationStatus?
    private var state: State = .Unknown


    enum State {
        case NoUser
        case UserApplied
        case UserNoApplication
        case UserConfirmed
        case Unknown
        case Updating
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        informationDisplayContainer = SplashInformationView.fromNib()
        statusDisplayContainer = SplashStatusView.fromNib()
        informationDisplayContainer.delegate = self
        statusDisplayContainer.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK:- Lifecycle

    override func viewDidLoad() {
        loadCurrentConference()
        loadingSpinner.startAnimating()
        informationDisplayContainer.alpha = 0.0
        statusDisplayContainer.alpha = 0.0
    }

    override func viewWillAppear(animated: Bool) {
        checkStatus()
        setNeedsStatusBarAppearanceUpdate()
    }

    private func updateView() {
        loadingSpinner.stopAnimating()
        informationDisplayContainer.removeFromSuperview()
        statusDisplayContainer.removeFromSuperview()
        var statusAlpha: CGFloat = 0.0
        var informationAlpha: CGFloat = 1.0

        switch state {
        case .NoUser:
            installContent(informationDisplayContainer)
            statusAlpha = 0.0
            informationAlpha = 1.0
            informationDisplayContainer.signInOut.setTitle("Sign in", forState: .Normal)
            break
        case .UserNoApplication:
            installContent(informationDisplayContainer)
            statusAlpha = 0.0
            informationAlpha = 1.0

            informationDisplayContainer.signInOut.setTitle("Sign out", forState: .Normal)
            break
        case .UserConfirmed:
            NSNotificationCenter.defaultCenter().postNotificationName("shouldPresentTabs", object: nil)
            return
        case .UserApplied:
            // Display their status
            installContent(statusDisplayContainer)
            statusAlpha = 1.0
            informationAlpha = 0.0
            statusDisplayContainer.statusLabel.text = applicationStatus?.status
        case .Unknown, .Updating:
            return
        }


        UIView.animateWithDuration(1.0, animations: {
            self.installEmblemDemphasizingConstraints()
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
        umadQuery.findObjectsInBackgroundWithBlock { results, error in
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
                if let status = status {
                    self.state = .UserApplied
                    if status.status == "Confirmed" {
                        self.state = .UserConfirmed
                    }
                } else {
                    self.state = .UserNoApplication
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.updateView()
                }

            }
        } else {
            state = .NoUser
            updateView()
        }
    }

    // MARK:- Animation

    private func installEmblemDemphasizingConstraints() {
        guard let oldConstraint = eventImageCenterYConstraint else {
            return
        }
        oldConstraint.active = false
        eventImage.removeConstraint(oldConstraint)
        let top = eventImage.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 40.0)
        top.active = true
    }

    private func installContent(content: UIView) {
        view.addSubview(content)
        let left = view.leftAnchor.constraintEqualToAnchor(content.leftAnchor, constant: -30.0)
        let right = view.rightAnchor.constraintEqualToAnchor(content.rightAnchor, constant: 30.0)
        let bottom = content.bottomAnchor.constraintLessThanOrEqualToAnchor(view.bottomAnchor, constant: -30.0)
        let top = content.topAnchor.constraintEqualToAnchor(eventImage.bottomAnchor, constant: 50.0)

        NSLayoutConstraint.activateConstraints([left, right, bottom, top])
        content.backgroundColor = .clearColor()
        content.translatesAutoresizingMaskIntoConstraints = false
        view.layoutIfNeeded()
        content.layoutIfNeeded()
    }


    // MARK:- View Delegate

    func openApplication() {
        let controller = SFSafariViewController(URL: NSURL(string: "http://umad.me")!)
        presentViewController(controller, animated: true, completion: nil)
    }

    func openSite() {
        let controller = SFSafariViewController(URL: NSURL(string: "http://umad.me")!)
        presentViewController(controller, animated: true, completion: nil)
    }

    func needsSignout() {
        signInOut()
        updateView()
    }

    func needsLogin() {
        signInOut()
        updateView()
    }

    func signInOut() {
        if User.currentUser() != nil {
            User.logOut()
            updateView()
            return
        }

        let logInNavController = LogInViewController.loadFromStoryboard()
        if let logIn = logInNavController.topViewController as? LogInViewController {
            logIn.delegate = self
        }

        presentViewController(logInNavController, animated: true, completion: nil)
    }

    // MARK:- Log In
    func didLogIn() {
        checkStatus()
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}
