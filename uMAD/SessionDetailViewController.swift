import Foundation
import UIKit
import SafariServices
import Parse

class SessionDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var infoLabel: Label!
    @IBOutlet weak var descriptionLabel: Label!
    @IBOutlet weak var dateLabel: Label!
    @IBOutlet weak var favoriteButton: CustomButton!
    @IBOutlet weak var websiteButton: CustomButton!
    
    weak var session: Session!
    var eventURL: NSURL?

    private let addFavoriteText = "Add to Favorites"
    private let removeFavoriteText = "Remove from Favorites"

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpData(session.company)
        
        favoriteButton.addTarget(self, action: "didTapFavoriteButton", forControlEvents: .TouchUpInside)
        websiteButton.addTarget(self, action: "didTapWebsiteButton", forControlEvents: .TouchUpInside)

        favoriteButton.setTitle(self.removeFavoriteText, forState: .Selected)
        favoriteButton.setTitle(self.addFavoriteText, forState: .Normal)
        
        session.company?.fetchIfNeededInBackgroundWithBlock { (company, error) -> Void in
            guard let company = company as? Company else {
                return
            }
            
            self.setUpData(company)
        }
        
        PFUser.currentUser()?.fetchFavoritesWithCompletion { favorites in
            let favorited = !favorites.filter { $0.objectId == self.session.objectId }.isEmpty
            self.favoriteButton.selected = favorited
        }
    }
    
    private func setUpData(company: Company?) {
        navigationItem.title = company?.name ?? "Session Info"
        eventURL = company?.websiteURL
        titleLabel.text = session.name

        if !(session.speaker.isEmpty || session.room.isEmpty) {
            infoLabel.text = "\(session.speaker) | \(session.room)"
        } else {
            infoLabel.text = "\(session.speaker)\(session.room)"
        }
        
        descriptionLabel.text = session.descriptionText
        
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
        if favoriteButton.selected == false {
            favoriteButton.selected = true
            session?.addToFavorites { success, error in
                if success && error == nil {
                    self.favoriteButton.setTitle(self.removeFavoriteText, forState: UIControlState.init(rawValue: 5))
                } else {
                    self.favoriteButton.selected = false
                }
            }
        } else {
            favoriteButton.selected = false
            session?.removeFromFavorites{ success, error in
                if success && error == nil {
                    self.favoriteButton.setTitle(self.addFavoriteText, forState: UIControlState.init(rawValue: 5))
                } else {
                    self.favoriteButton.selected = true
                }
            }

        }
    }
}
