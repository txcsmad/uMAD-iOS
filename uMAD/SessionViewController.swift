import UIKit
import SafariServices
import Parse

class SessionViewController: UITableViewController {
    
    weak var session: Session!
    var eventURL: NSURL?
    let websiteCellIdentifier = "websiteCell"
    
    var addToFavoritesBarButtonItem: UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "favorite-stroked"), style: .Plain, target: self, action: "addToFavorites:")
    }
    var removeFromFavoritesBarButtonItem: UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "favorite"), style: .Plain, target: self, action: "removeFromFavorites:")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Session Info"
        view.backgroundColor = UIColor.whiteColor()

        session.company?.fetchIfNeededInBackgroundWithBlock { (company, error) -> Void in
            guard let company = company as? Company else {
                return
            }
            self.eventURL = company.websiteURL
            self.tableView.reloadData()
        }
        tableView.estimatedRowHeight = 200
        automaticallyAdjustsScrollViewInsets = true
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 20.0) )
        tableView.tableHeaderView = nil
        tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0)
        
        PFUser.currentUser()?.fetchFavoritesWithCompletion { favorites in
            let favorited = !favorites.filter { $0.objectId == self.session.objectId }.isEmpty
            self.navigationItem.rightBarButtonItem = favorited ? self.removeFromFavoritesBarButtonItem : self.addToFavoritesBarButtonItem
        }
    }
    
    func addToFavorites(sender: UIBarButtonItem) {
        session.incrementKey("favoriteCount")
        session.saveInBackground()
        
        let favorites = PFUser.currentUser()?.relationForKey("favorites")
        favorites?.addObject(session)
        PFUser.currentUser()?.saveInBackgroundWithBlock { success, error in
            if success {
                self.navigationItem.rightBarButtonItem = self.removeFromFavoritesBarButtonItem
            }
        }
    }
    
    func removeFromFavorites(sender: UIBarButtonItem) {
        session.incrementKey("favoriteCount", byAmount: -1)
        session.saveInBackground()
        
        let favorites = PFUser.currentUser()?.relationForKey("favorites")
        favorites?.removeObject(session)
        PFUser.currentUser()?.saveInBackgroundWithBlock { success, error in
            if success {
                self.navigationItem.rightBarButtonItem = self.addToFavoritesBarButtonItem
            }
        }
    }

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row == 1
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
             tableView.deselectRowAtIndexPath(indexPath, animated: false)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if eventURL != nil {
                let webViewController = SFSafariViewController(URL: session.company!.websiteURL)
                webViewController.view.tintColor = Config.tintColor
                PFAnalytics.trackEventInBackground("openedSponsorWebsite", dimensions:nil, block: nil)
                navigationController?.pushViewController(webViewController, animated: true)
            }
        }

    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if eventURL != nil {
            return 2
        }
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch indexPath.row {
        case 0:
            let nib = NSBundle.mainBundle().loadNibNamed("EventHeaderView", owner: self, options: nil).first
            guard let headerView = nib as? EventHeaderView else {
                return UITableViewCell()
            }
            headerView.sessionDescription.preferredMaxLayoutWidth = 300
            headerView.configure(session)
            cell = headerView

        case 1:
            cell = UITableViewCell()
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.text = eventURL?.absoluteString

        default:
            cell = UITableViewCell()
        }
        return cell
    }
}
