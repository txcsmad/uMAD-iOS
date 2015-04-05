import UIKit

let eventCellIdentifier = "eventsCell"

class EventsViewController: UITableViewController {

    private var events: [Event]?
    private var sections = [Int: [Event]]()
    private let sectionHeaderFormatter = NSDateFormatter()
    private let searchController = UISearchController()

    override func viewDidLoad() {
        super.viewDidLoad()
        sectionHeaderFormatter.timeZone = NSTimeZone(name: "UTC")
        sectionHeaderFormatter.dateFormat = "EEEE - hh:mm a";

        navigationItem.title = "Events"

        tableView.registerClass(EventTableViewCell.self, forCellReuseIdentifier: eventCellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: Selector("reloadData"), forControlEvents: .ValueChanged)
        
        reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setToolbarHidden(true, animated: true)
    }

    func reloadData() {
        fetchEvents()
    }

    private func fetchEvents(){

        var eventQuery = PFQuery(className:"Event")
        eventQuery.cachePolicy = .CacheThenNetwork;
        eventQuery.orderByAscending("startTime")
        eventQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) in
            if error != nil {
                // Log details of the failure
                //println("Error: %@ %@", error, error!.userInfo!)
                return
            }
            self.events = objects as! [Event]?

            self.createSectionedRepresentation()

            dispatch_async(dispatch_get_main_queue(), { () in
                UIView.transitionWithView(self.tableView, duration: 0.1, options: UIViewAnimationOptions.ShowHideTransitionViews, animations: {
                    () -> Void in

                    let delayTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.20 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.refreshControl!.endRefreshing()
                    }

                    self.tableView.reloadData()
                    }, completion: nil)
            })
        }

    }

    private func createSectionedRepresentation(){
        if events == nil {
            return
        }
        let calendar = NSCalendar.currentCalendar()
        let desiredComponents = (NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitDay)
        var currentSection = 0
        var comparisonIndex = 0;
        var comparisonEvent = events![comparisonIndex]
        var newSection = [Event]()
        newSection.append(comparisonEvent)
        sections[currentSection] = newSection
        var comparisonComponents = calendar.components(desiredComponents, fromDate: comparisonEvent.startTime)
        for var i = 1; i < events!.count; i++ {
            let currentEvent = events![i]

            let currentComponents = calendar.components( desiredComponents, fromDate:currentEvent.startTime)
            if comparisonComponents.hour != currentComponents.hour ||
                comparisonComponents.day != currentComponents.day {
                    currentSection++
                    var newSection = [Event]()
                    newSection.append(currentEvent)
                    sections[currentSection] = newSection
                    comparisonIndex = i
                    comparisonEvent = events![comparisonIndex]
                    comparisonComponents = calendar.components(desiredComponents, fromDate: comparisonEvent.startTime)

            } else {
                sections[currentSection]!.append(currentEvent)
            }
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]!
        return section.count
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel.font = UIFont(name: "HelveticaNeue-Bold", size: UIFont.systemFontSize())
        header.textLabel.text = header.textLabel.text!.uppercaseString
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = sections[indexPath.section]!

        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let event = section[indexPath.row]
        let eventViewController = EventViewController(event: event)
        
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        let sectionTime = section![0].startTime
        return sectionHeaderFormatter.stringFromDate(sectionTime)

    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(eventCellIdentifier, forIndexPath: indexPath) as! EventTableViewCell

        let section = sections[indexPath.section]
        let event = section![indexPath.row]
        cell.configure(event)
        
        return cell
    }
}