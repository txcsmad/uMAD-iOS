import UIKit

let EVENTS_TABLEVIEW_CELL_IDENTIFIER: String = "eventsCell"
let EVENTS_TABLEVIEW_CELL_HEIGHT: CGFloat = 65.00

class EventsViewController: UITableViewController {

    private var events = [Event]()
    private var sections = [Int: [EventReference]]() // Section index -> arrays of weak references to events
    private var logos = [Int: UIImage]() // Company ID -> UImage
    private let sectionHeaderFormatter: NSDateFormatter = NSDateFormatter()
    private let timeFormatter: NSDateFormatter  = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        sectionHeaderFormatter.timeZone = NSTimeZone(name: "UTC")
        sectionHeaderFormatter.dateFormat = "MMMM d - hh:00 a";

        timeFormatter.timeZone              = NSTimeZone(name: "UTC")
        timeFormatter.dateFormat            = "hh:mm a";
        navigationItem.title = "Events"
        
        tableView.registerClass(EventTableViewCell.self, forCellReuseIdentifier: EVENTS_TABLEVIEW_CELL_IDENTIFIER)
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
        fetchThumbnails()
    }

    private func fetchEvents(){
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
            }

            //Sort the events from earliest to latest
            self.events = self.events.sorted({
                (firstEvent: Event, secondEvent: Event) -> Bool in
                let result = firstEvent.startTime!.compare(secondEvent.startTime!)
                return  result == .OrderedAscending
            })

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
    private func fetchThumbnails(){
        var sponsorsQuery: PFQuery = PFQuery(className: "Sponsors")
        sponsorsQuery.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) in
            if error != nil {
                println("Error: %@ %@", error, error.userInfo!)
                return
            }
            for object in objects {
                if let companyID = object["identifierNumber"] as? Int {
                    if let imageFile: PFFile = object["thumbnail"] as? PFFile {
                        imageFile.getDataInBackgroundWithBlock({
                            (data: NSData!, error: NSError!) -> Void in
                            if data != nil {
                                self.logos[companyID] = UIImage(data: data)
                                //FIXME: It's inefficient to do this so many times
                                self.tableView.reloadData()
                            } else if error != nil {
                                println(error.localizedDescription)
                            }
                        })
                    }
                }
            }

        })
    }
    private func createSectionedRepresentation(){
        let calendar = NSCalendar.currentCalendar()
        let desiredComponents = (NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitDay)
        var currentSection = 0
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
                    comparisonIndex = i
                    comparisonEvent = self.events[comparisonIndex]
                    comparisonComponents = calendar.components(desiredComponents, fromDate: comparisonEvent.startTime!)

            } else {
                self.sections[currentSection]!.append(EventReference(event: currentEvent))
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
        

        let event = section[indexPath.row].referenced!

        var thumbnail = logos[event.companyID!]
        if thumbnail == nil {
             thumbnail = UIImage(named: "mad_thumbnail.png")!
        }

        
        let eventViewController = EventViewController(image: thumbnail!, event: event)
        
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(EVENTS_TABLEVIEW_CELL_IDENTIFIER, forIndexPath: indexPath) as! UITableViewCell
        let section = sections[indexPath.section]
        let event = section![indexPath.row].referenced!

        var startTimeString: String         = "00:00"
        var endTimeString: String           = "00:00"
        
        if let startTime: NSDate = event.startTime {
            startTimeString = timeFormatter.stringFromDate(startTime)
        }
        
        if let endTime: NSDate = event.endTime {
            endTimeString = timeFormatter.stringFromDate(endTime)
        }

        cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        
        cell.textLabel?.text        = event.sessionName
        cell.detailTextLabel?.text  = "\(startTimeString) - \(endTimeString) – \(event.room!)"

        cell.imageView?.image       =  UIImage(named: "mad_thumbnail.png")?.imageScaledToSize(CGSizeMake(50, 50))
        if let logo = logos[event.companyID!]{
            cell.imageView?.image = logo.imageScaledToSize(CGSizeMake(50.00, 50.00))
        }

        
        return cell
    }
}