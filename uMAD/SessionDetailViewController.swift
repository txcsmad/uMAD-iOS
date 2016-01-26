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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpData(session.company)
        
        favoriteButton.addTarget(self, action: "didTapFavoriteButton", forControlEvents: .TouchUpInside)
        websiteButton.addTarget(self, action: "didTapWebsiteButton", forControlEvents: .TouchUpInside)
        
        
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
    
    //MARK: - Favorite Functions
    
    private func addToFavorites() {
        session.incrementKey("favoriteCount")
        session.saveInBackground()
        
        let favorites = PFUser.currentUser()?.relationForKey("favorites")
        favorites?.addObject(session)
        PFUser.currentUser()?.saveInBackgroundWithBlock { success, error in
            self.favoriteButton.selected = success
            
        }
    }
    
    private func removeFromFavorites() {
        session.incrementKey("favoriteCount", byAmount: -1)
        session.saveInBackground()
        
        let favorites = PFUser.currentUser()?.relationForKey("favorites")
        favorites?.removeObject(session)
        PFUser.currentUser()?.saveInBackgroundWithBlock { success, error in
            if success {
                self.favoriteButton.selected = false
            } else {
                self.favoriteButton.selected = true
            }
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
            addToFavorites()
        } else {
            favoriteButton.selected = false
            removeFromFavorites()
        }
    }
}
