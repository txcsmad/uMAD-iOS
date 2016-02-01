import Foundation
import UIKit
import Parse
import ParseUI

class MyScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var favorites: [Session]?
    var sectionedFavorites: [[Session]]?
    let tableView = UITableView()

    let cellIdentifier = "favs"
    var displayingFavorites = false

    // MARK:- Init
    static func fromStoryboard() -> MyScheduleViewController {
        return UIStoryboard(name: "MySchedule", bundle: nil).instantiateViewControllerWithIdentifier("MyScheduleViewController") as! MyScheduleViewController
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "SessionTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "favoritesDidChange", name: "favoritesDidChange", object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        updateView()

        if displayingFavorites {
            tableView.reloadData()
        }
    }

    func favoritesDidChange() {
        updateView()
        tableView.reloadData()
    }
    func updateView() {
        if let favorites = User.currentUser()?.favorites
            where displayingFavorites == false {
                displayingFavorites = true
                self.favorites = favorites.sort { $0.startTime.compare($1.startTime) == .OrderedAscending}
                self.sectionedFavorites = self.favorites!.createSectionedRepresentation()
                view.subviews.forEach { $0.removeFromSuperview() }
                view.addSubview(tableView)
                tableView.translatesAutoresizingMaskIntoConstraints = false
                view.topAnchor.constraintEqualToAnchor(tableView.topAnchor).active = true
                view.rightAnchor.constraintEqualToAnchor(tableView.rightAnchor).active = true
                view.heightAnchor.constraintEqualToAnchor(tableView.heightAnchor).active = true
                view.widthAnchor.constraintEqualToAnchor(tableView.widthAnchor).active = true
                tableView.reloadData()
        }
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

}