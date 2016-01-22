import Parse
import ParseUI
import SafariServices

class SessionsViewController: PFQueryTableViewController, UISearchControllerDelegate,
UISearchResultsUpdating, UISearchBarDelegate, PFLogInViewControllerDelegate, ProfileViewControllerDelegate {

    private var sessions: [Session]?
    private var sections = [[Session]]()
    private var filteredSessions: [Session]?
    private var filteredSections = [[Session]]()
    private let sectionHeaderFormatter = NSDateFormatter()
    private var searchController: UISearchController!
    private let cellIdentifier = "SessionCell"

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Sessions"

        tableView.registerClass(SessionTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = 64
        tableView.separatorInset = UIEdgeInsetsZero

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["All"]
        searchController.searchBar.placeholder = "Search Events"
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true

        sectionHeaderFormatter.timeZone = NSTimeZone.localTimeZone()
        sectionHeaderFormatter.dateFormat = "EEEE - hh:mm a"

        pullToRefreshEnabled = true
        paginationEnabled = false

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "user.png"), style: .Plain, target: self, action: "didTapRightBarItem")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setToolbarHidden(true, animated: true)
    }

    // MARK: - PFQueryTableViewController

    override func queryForTable() -> PFQuery {
        let query = Session.query()!
        query.cachePolicy = .CacheThenNetwork

        query.includeKey("company")
        // If we know the current uMAD, only list sessions for it.
        if let currentUMAD = AppDelegate.currentUMAD {
            query.whereKey("umad", equalTo: currentUMAD)
        }
        query.orderByAscending("startTime")

        return query
    }

    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)

        guard let casted = objects as? [Session] else {
            return
        }

        sessions?.removeAll()
        sections.removeAll()
        filteredSessions?.removeAll()
        filteredSections.removeAll()
        sessions = casted
        sections = sessions!.createSectionedRepresentation()
        searchController.searchBar.scopeButtonTitles = getTopTags()
    }

    override func objectAtIndexPath(indexPath: NSIndexPath?) -> PFObject? {
        return searchController.active ? filteredSections[indexPath!.section][indexPath!.row] : sections[indexPath!.section][indexPath!.row]
    }

    func sessionAtIndexPath(indexPath: NSIndexPath) -> Session? {
        return objectAtIndexPath(indexPath) as? Session
    }

    // MARK: - UITableViewController

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? SessionTableViewCell else {
            return UITableViewCell()
        }

        if let session = objectAtIndexPath(indexPath) as? Session {
            cell.configureForSession(session)
        }

        return cell
    }

    // MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = (searchController.active) ? filteredSections[section] : sections[section]
        return section.count
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (searchController.active) ? filteredSections.count : sections.count
    }

    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {
            return
        }
        header.textLabel!.font = UIFont(name: "HelveticaNeue-Bold", size: UIFont.systemFontSize())
        header.textLabel!.text = header.textLabel!.text!.uppercaseString
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let session = sessionAtIndexPath(indexPath)!
        let sessionViewController = SessionViewController()
        sessionViewController.session = session
        navigationController?.pushViewController(sessionViewController, animated: true)
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = (searchController.active) ? filteredSections[section] : sections[section]
        let sectionTime = section[0].startTime
        return sectionHeaderFormatter.stringFromDate(sectionTime)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }

    //MARK: - Login
    func didTapRightBarItem() {
        // User is not logged in
        if PFUser.currentUser() == nil {
            let logInViewController = LogInViewController()
            logInViewController.delegate = self
            logInViewController.emailAsUsername = true
            logInViewController.logInView?.logo = UIImageView(image: UIImage(named: "organization-logo.png"))
            presentViewController(logInViewController, animated: true, completion: nil)
        } else {
            let navController = UIStoryboard(name: "Profile", bundle: NSBundle.mainBundle()).instantiateInitialViewController()!
            guard let profileController = navController.childViewControllers.first as? ProfileViewController else {
                return
            }
            profileController.delegate = self
            // User is logged in. Present profile view
            presentViewController(navController, animated: true, completion: nil)
        }
    }

    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        // TODO: Change the icon?
        // Dismiss the login view controller
        dismissViewControllerAnimated(true, completion: nil)
    }

    func userDidExitProfile() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    //MARK: - Search

    func getTopTags() -> [String]? {
        guard sessions != nil else {
            return nil
        }

        var tags = [String: Int]()
        for event in sessions! {
            for tag in event.topicTagsSet {
                let oldValue = tags[tag] ?? 0
                tags[tag] = 1 + oldValue
            }
        }
        let byDescendingOccurrences = tags.sort { $0.1 > $1.1 }
        let numTags = byDescendingOccurrences.count
        var scopeTags = [String]()
        scopeTags.append("All")
        for var i = 0; i < 3 && (i < numTags - 1); i++ {
            scopeTags.append(byDescendingOccurrences[i].0)
        }
        return scopeTags
    }

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        filterContentForSearchText(searchString!, scope: searchController.searchBar.selectedScopeButtonIndex)
        tableView.reloadData()
    }

    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(searchController)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResultsForSearchController(searchController)
    }

    func filterContentForSearchText(searchText: String, scope: Int) {
        let buttonTitles = searchController.searchBar.scopeButtonTitles!
        let scopeString = buttonTitles[scope]
        filteredSessions = sessions!.filter { event in
            let categoryMatch = (scopeString == "All") || (event.topicTagsSet.contains(scopeString))
            if searchText != "" {
                let stringMatch = event.name.rangeOfString(searchText, options: .CaseInsensitiveSearch)
                return categoryMatch && (stringMatch != nil)
            } else {
                return categoryMatch
            }
        }

        filteredSections = filteredSessions!.createSectionedRepresentation()
    }

}
