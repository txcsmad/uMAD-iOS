import Foundation
import UIKit
import SafariServices
import Parse

class SessionDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var infoLabel: Label!
    @IBOutlet weak var capacityWarningLabel: UILabel!
    @IBOutlet weak var descriptionLabel: Label!
    @IBOutlet weak var speakerSectionHead: UILabel!
    @IBOutlet weak var speakerBioLabel: Label!
    @IBOutlet weak var dateLabel: Label!
    @IBOutlet weak var favoriteButton: CustomButton!
    @IBOutlet weak var websiteButton: CustomButton!

    weak var session: Session!
    var eventURL: NSURL?

    private let addFavoriteText = "Add to my schedule"
    private let removeFavoriteText = "Remove from my schedule"

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpData(session)

        favoriteButton.addTarget(self, action: "didTapFavoriteButton", forControlEvents: .TouchUpInside)
        websiteButton.addTarget(self, action: "didTapWebsiteButton", forControlEvents: .TouchUpInside)

        favoriteButton.setTitle(self.removeFavoriteText, forState: .Selected)
        favoriteButton.setTitle(self.addFavoriteText, forState: .Normal)

        session.company?.fetchIfNeededInBackgroundWithBlock { company, error in
            self.setUpData(self.session)
        }

    }

    private func setUpData(session: Session) {
        let company = session.company
        navigationItem.title = company?.name ?? "Session Info"
        eventURL = company?.websiteURL
        titleLabel.text = session.name

        if !(session.speaker.isEmpty || session.room.isEmpty) {
            infoLabel.text = "\(session.speaker) | \(session.room)"
        } else {
            infoLabel.text = "\(session.speaker)\(session.room)"
        }

        descriptionLabel.text = session.descriptionText
        speakerBioLabel.text = session.bio

        if session.bio == nil {
            speakerSectionHead.hidden = true
            speakerSectionHead.removeFromSuperview()
            speakerBioLabel.removeFromSuperview()
            descriptionLabel.bottomAnchor.constraintEqualToAnchor(dateLabel.topAnchor, constant: -8.0).active = true
        }

        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, h:mm"
        let startTimeString = formatter.stringFromDate(session.startTime)
        formatter.dateFormat = "h:mm a"
        dateLabel.text = "\(startTimeString) - \(formatter.stringFromDate(session.endTime))"

        if eventURL != nil {
            websiteButton.alpha = 1
        } else {
            websiteButton.alpha = 0
        }

        favoriteButton.selected = session.isFavorited()
        if session.atCapacity {
            capacityWarningLabel.alpha = 1.0
        } else {
            capacityWarningLabel.alpha = 0.0
            capacityWarningLabel.removeFromSuperview()
            infoLabel.bottomAnchor.constraintEqualToAnchor(descriptionLabel.topAnchor, constant: -8.0).active = true
        }
    }

    //MARK: - Button Functions

    func didTapWebsiteButton() {
        if eventURL != nil {
            let webViewController = SFSafariViewController(URL: session.company!.websiteURL)
            webViewController.view.tintColor = Config.tintColor
            PFAnalytics.trackEventInBackground("openedSponsorWebsite", dimensions:nil, block: nil)
            presentViewController(webViewController, animated: true, completion: nil)
        }
    }

    func didTapFavoriteButton() {
        guard let session = session,
           favorites = User.currentUser()?.favorites else {
            return
        }

        if let overlapsWith = session.wouldCreateNewOverlapWith(favorites) {
            presentFavoritesOverlapAlert(overlapsWith)
            return
        }

        if favoriteButton.selected == false {
            favoriteButton.selected = true
            session.addToFavorites { success, error in
                if success && error == nil {
                    self.favoriteButton.setTitle(self.removeFavoriteText, forState: UIControlState.init(rawValue: 5))
                } else {
                    self.favoriteButton.selected = false
                }
            }
        } else {
            favoriteButton.selected = false
            session.removeFromFavorites { success, error in
                if success && error == nil {
                    self.favoriteButton.setTitle(self.addFavoriteText, forState: UIControlState.init(rawValue: 5))
                } else {
                    self.favoriteButton.selected = true
                }
            }

        }
    }
    /**
     Presents an alert notifying the user that adding a favorite
     would create a conflict with the passed in session. Allows
     them to unfavorite the session, or acknowledge

     - parameter session: the session that would conflict with the desired favorite
     */
    func presentFavoritesOverlapAlert(session: Session) {
        let controller = UIAlertController(title: "Overlapping Sessions",
            message: "This session overlaps with another on your schedule, \"\(session.name).\"", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Remove conflicting session", style: .Default) { _ in
            session.removeFromFavorites { success, error -> () in
                if success && error == nil {
                    // Run the action as if they were retapping the button, just with no conflict now!
                    self.didTapFavoriteButton()
                }
            }
        })
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(controller, animated: true, completion: nil)
    }
}
