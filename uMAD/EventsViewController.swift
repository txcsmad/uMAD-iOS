
import UIKit

class EventsViewController: UITableViewController {

    private var events = [Event]()
    private var sections = [Int: [EventReference]]()// Section index -> arrays of weak references to events
    private var logos = [String: UIImage]()
    private let sectionHeaderFormatter: NSDateFormatter = NSDateFormatter()
    private let timeFormatter: NSDateFormatter  = NSDateFormatter()


    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        sectionHeaderFormatter.timeZone = NSTimeZone(name: "UTC")
        sectionHeaderFormatter.dateFormat = "MMMM d - hh:00 a";

        timeFormatter.timeZone              = NSTimeZone(name: "UTC")
        timeFormatter.dateFormat            = "hh:mm a";
        self.navigationItem.title = "Events"
        
        self.tableView.registerClass(EventTableViewCell.self, forCellReuseIdentifier: EVENTS_TABLEVIEW_CELL_IDENTIFIER)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: Selector("reloadData"), forControlEvents: .ValueChanged)
        
        reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }

    func reloadData() {
        var eventsQuery: PFQuery = PFQuery(className:"Events")
        eventsQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) in
            if error != nil {
                // Log details of the failure
                println("Error: %@ %@", error, error.userInfo!)
                return
            }
                self.events = [Event]()

                for object in objects {
                    self.events.append(Event(parseReturn: object))
                    println(self.events.last!.stringDescription())
                }

                //Sort the events from earliest to latest
                self.events = self.events.sorted({
                    (firstEvent: Event, secondEvent: Event) -> Bool in
                    let result = firstEvent.startTime!.compare(secondEvent.startTime!)
                    return  result == .OrderedAscending
                })

                let calendar = NSCalendar.currentCalendar()
                let desiredComponents = (NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitDay)
                var currentSection = 0;

                //FIXME: what about the 0 event case?
                var comparisonIndex = 0;
                var comparisonEvent = self.events[comparisonIndex]
                var newSection = [EventReference]()
                newSection.append(EventReference(event: comparisonEvent))
                self.sections[currentSection] = newSection
                var comparisonComponents = calendar.components(desiredComponents, fromDate: comparisonEvent.startTime!)
                for var i = 1; i < self.events.count; i++ {
                    let currentEvent = self.events[i]

                    let currentComponents = calendar.components( desiredComponents, fromDate:currentEvent.startTime!)
                    if comparisonComponents.hour != currentComponents.hour ||
                        comparisonComponents.day != currentComponents.day {
                        currentSection++
                        var newSection = [EventReference]()
                        newSection.append(EventReference(event: currentEvent))
                        self.sections[currentSection] = newSection
                        comparisonIndex++
                        comparisonEvent = self.events[comparisonIndex]
                        comparisonComponents = calendar.components(desiredComponents, fromDate: comparisonEvent.startTime!)

                    } else {

                        var section = self.sections[currentSection]!
                        section.append(EventReference(event: currentEvent))
                    }
                }
                
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
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]!
        return section.count
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = sections[indexPath.section]!

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        

        let event = section[indexPath.row].referenced!
        let thumbnail: UIImage = UIImage(named: "mad_thumbnail.png")!
        
        var eventViewController: EventViewController = EventViewController(image: thumbnail, event: event)
        
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return EVENTS_TABLEVIEW_CELL_HEIGHT
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        let sectionTime = section![0].referenced!.startTime!
        return sectionHeaderFormatter.stringFromDate(sectionTime)

    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        var sectionHeaderView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        sectionHeaderView.textLabel.font = UIFont.systemFontOfSize(FONT_SIZE)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("EVENTS_TABLEVIEW_CELL_IDENTIFIER", forIndexPath: indexPath) as! EventTableViewCell
        let section = sections[indexPath.section]
        let event = section![indexPath.row].referenced!
        let companyName: String? = event.companyName
        let sessionName: String? = event.sessionName
        let startTime: NSDate?   = event.startTime
        let endTime: NSDate?     = event.endTime
        let room: String?        = event.room
        let companyIDNumber: NSNumber? = event.companyID
        let companyIDString: String? = event.companyID?.stringValue
        

        var startTimeString: String         = "00:00"
        var endTimeString: String           = "00:00"
        
        if let time: NSDate = startTime {
            startTimeString = timeFormatter.stringFromDate(time)
        }
        
        if let time: NSDate = endTime {
            endTimeString = timeFormatter.stringFromDate(time)
        }
        
        cell.textLabel?.font = UIFont.systemFontOfSize(FONT_SIZE)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(DETAIL_FONT_SIZE)
        
        cell.textLabel?.text        = companyName
        cell.detailTextLabel?.text  = sessionName
        cell.timeLabel?.text        = startTimeString + " - " + endTimeString
        cell.locationLabel?.text    = room
        cell.imageView?.image       = UIImage(named: "mad_thumbnail.png")?.imageScaledToSize(CGSizeMake(50, 50))
        
        return cell
    }
}