import Foundation
import UIKit
import Parse
import ParseUI

class MyScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var favorites: [Session]?
    var sectionedFavorites: [[Session]]?
    let tableView = UITableView()

    let cellIdentifier = "SessionCell"
    var displayingFavorites = false

    // MARK:- Init
    static func fromStoryboard() -> MyScheduleViewController {
        return UIStoryboard(name: "MySchedule", bundle: nil).instantiateViewControllerWithIdentifier("MyScheduleViewController") as! MyScheduleViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "favoritesDidChange", name: "favoritesDidChange", object: nil)
        tableView.registerNib(UINib(nibName: "SessionTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        favoritesDidChange()
    }

    override func viewWillAppear(animated: Bool) {
        updateView()
    }

    func queryForTable() -> PFQuery {
        guard let query = User.currentUser()?.relationForKey("favorites").query() else {
            return PFQuery()
        }
        query.cachePolicy = .CacheThenNetwork

        query.includeKey("company")

        // If we know the current uMAD, only list sessions for it.
        if let currentUMAD = AppDelegate.currentUMAD {
            query.whereKey("umad", equalTo: currentUMAD)
        }
        query.orderByAscending("startTime")

        return query
    }

    //MARK:-

    func favoritesDidChange() {
        queryForTable().findObjectsInBackgroundWithBlock { objects, error in
            guard let favs = objects as? [Session] where error == nil else {
                return
            }
            self.favorites = favs.sort { $0.startTime.compare($1.startTime) == .OrderedAscending}
            self.sectionedFavorites = self.favorites!.createSectionedRepresentation()
            self.updateView()
        }

    }

    func updateView() {
        if let favorites = favorites
            where displayingFavorites == false && favorites.count > 0 {
                displayingFavorites = true
                view.subviews.forEach { $0.removeFromSuperview() }
                view.addSubview(tableView)
                tableView.delegate = self
                tableView.dataSource = self
                tableView.translatesAutoresizingMaskIntoConstraints = false
                view.topAnchor.constraintEqualToAnchor(tableView.topAnchor).active = true
                view.rightAnchor.constraintEqualToAnchor(tableView.rightAnchor).active = true
                view.heightAnchor.constraintEqualToAnchor(tableView.heightAnchor).active = true
                view.widthAnchor.constraintEqualToAnchor(tableView.widthAnchor).active = true
                tableView.reloadData()
        }
        tableView.reloadData()
    }


    func sessionAtIndexPath(indexPath: NSIndexPath) -> Session? {
        return sectionedFavorites?[indexPath.section][indexPath.row]
    }

    // MARK:- UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let session = sessionAtIndexPath(indexPath),
            cell = tableView
                .dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? SessionTableViewCell else {
            return UITableViewCell()
        }
        cell.configureForSession(session)
        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionedFavorites?.count ?? 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionedFavorites?[section].count ?? 0
    }

    //MARK:- UITableViewDelegate 

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        guard let session = sessionAtIndexPath(indexPath) else {
            return
        }
        let sessionViewController = UIStoryboard(name: "Sessions", bundle: nil)
            .instantiateViewControllerWithIdentifier("SessionDetailViewController") as! SessionDetailViewController
        sessionViewController.session = session
        navigationController?.pushViewController(sessionViewController, animated: true)
    }

   func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sectionedFavorites![section]
        let sectionTime = section[0].startTime
        // Add some left padding. Definitely a hack.
        return NSDateFormatter.localizedStringFromDate(sectionTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }

}