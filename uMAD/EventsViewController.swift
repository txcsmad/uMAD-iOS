import UIKit

let eventCellIdentifier = "eventsCell"

class EventsViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    private var events: [Event]?
    private var sections = [[Event]]()
    private var filteredEvents: [Event]?
    private var filteredSections = [[Event]]()
    private let sectionHeaderFormatter = NSDateFormatter()
    private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["All"]
        searchController.searchBar.placeholder = "Search Events"
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true

        sectionHeaderFormatter.timeZone = NSTimeZone(name: "UTC")
        sectionHeaderFormatter.dateFormat = "EEEE - hh:mm a";

        navigationItem.title = "Events"

        tableView.registerClass(EventTableViewCell.self, forCellReuseIdentifier: eventCellIdentifier)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: Selector("fetchEvents"), forControlEvents: .ValueChanged)
        
        fetchEvents()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setToolbarHidden(true, animated: true)
    }

    func fetchEvents(){

        var eventQuery = PFQuery(className:"Event")
        eventQuery.cachePolicy = .CacheThenNetwork;
        eventQuery.orderByAscending("startTime")
        eventQuery.findObjectsInBackgroundWithBlock {
            (objects, error) in
            if error != nil {
                // Log details of the failure
                //println("Error: %@ %@", error, error!.userInfo!)
                return
            }
            self.events = objects as! [Event]?

            self.sections = self.createSectionedRepresentation(self.events!)



            dispatch_async(dispatch_get_main_queue(), { _ in
                self.searchController.searchBar.scopeButtonTitles = self.getTopTags()
                UIView.transitionWithView(self.tableView, duration: 0.1, options: UIViewAnimationOptions.ShowHideTransitionViews, animations: {
                    () -> Void in

                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.20 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.refreshControl!.endRefreshing()
                    }
                    self.tableView.reloadData()
                    }, completion: nil)
            })
        }

    }

    private func createSectionedRepresentation(events: [Event]) -> [[Event]] {
        var newSections = [[Event]]()
        if events.count == 0 {
            return newSections
        }

        let calendar = NSCalendar.currentCalendar()
        let desiredComponents = (NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitDay)
        var currentSection = 0
        var comparisonIndex = 0
        var comparisonEvent = events[comparisonIndex]
        var newSection = [Event]()
        newSection.append(comparisonEvent)
        newSections.append(newSection)
        var comparisonComponents = calendar.components(desiredComponents, fromDate: comparisonEvent.startTime)
        for var i = 1; i < events.count; i++ {
            let currentEvent = events[i]

            let currentComponents = calendar.components( desiredComponents, fromDate:currentEvent.startTime)
            if comparisonComponents.hour != currentComponents.hour ||
                comparisonComponents.day != currentComponents.day {
                    currentSection++
                    var newSection = [Event]()
                    newSection.append(currentEvent)
                    newSections.append(newSection)
                    comparisonIndex = i
                    comparisonEvent = events[comparisonIndex]
                    comparisonComponents = calendar.components(desiredComponents, fromDate: comparisonEvent.startTime)

            } else {
                newSections[currentSection].append(currentEvent)
            }
        }
        return newSections
    }

    func getTopTags() -> [String]? {
        if self.events == nil {
            return nil
        }
        else {
            var tags = [String: Int]()
            for event in self.events! {
                for tag in event.topicTagsSet {
                    let oldValue = tags[tag] ?? 0
                    tags[tag] = 1 + oldValue
                }
            }
            let byDescendingOccurrences = sorted(tags){ $0.1 > $1.1 }
            let numTags = count(byDescendingOccurrences)
            var scopeTags = [String]()
            scopeTags.append("All")
            for var i = 0; i < 3 && (i < numTags - 1); i++ {
                scopeTags.append(byDescendingOccurrences[i].0)
            }
            return scopeTags
        }
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
        let header = view as! UITableViewHeaderFooterView
        header.textLabel.font = UIFont(name: "HelveticaNeue-Bold", size: UIFont.systemFontSize())
        header.textLabel.text = header.textLabel.text!.uppercaseString
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let section = (searchController.active) ? filteredSections[indexPath.section] : sections[indexPath.section]

        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let event: Event = section[indexPath.row]
        let eventViewController = EventViewController()
        eventViewController.event = event
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = (searchController.active) ? filteredSections[section] : sections[section]
        let sectionTime = section[0].startTime
        return sectionHeaderFormatter.stringFromDate(sectionTime)

    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(eventCellIdentifier, forIndexPath: indexPath) as! EventTableViewCell

        let section = (searchController.active) ? filteredSections[indexPath.section] : sections[indexPath.section]
        let event = section[indexPath.row]
        cell.configure(event)
        
        return cell
    }

    //MARK: - Search
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        filterContentForSearchText(searchString, scope: searchController.searchBar.selectedScopeButtonIndex)
        tableView.reloadData()
    }
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int){
        updateSearchResultsForSearchController(searchController)
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResultsForSearchController(searchController)
    }
    func filterContentForSearchText(searchText: String, scope: Int) {
        let buttonTitles = searchController.searchBar.scopeButtonTitles as! [String]
        let scopeString = buttonTitles[scope]
        filteredEvents = events!.filter({( event: Event) -> Bool in
            let categoryMatch = (scopeString == "All") || (event.topicTagsSet.contains(scopeString))
            if searchText != "" {
                event.name.rangeOfString("tesuteo!")
                let stringMatch = event.name.rangeOfString(searchText, options: .CaseInsensitiveSearch)
                return categoryMatch && (stringMatch != nil)
            } else {
                return categoryMatch
            }
        })

        filteredSections = createSectionedRepresentation(filteredEvents!)
    }

}