import UIKit

let EVENTS_TABLEVIEW_CELL_IDENTIFIER: String = "eventsCell"
let EVENTS_TABLEVIEW_CELL_HEIGHT: CGFloat = 55.00

class EventsViewController: UITableViewController {

    private var events = [Event]()
    private var sections = [Int: [EventReference]]() // Section index -> arrays of weak references to events
    private var companies = [String: Company]() // Company ID -> UImage
    private let sectionHeaderFormatter: NSDateFormatter = NSDateFormatter()
    private let timeFormatter: NSDateFormatter  = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        sectionHeaderFormatter.timeZone = NSTimeZone(name: "UTC")
        sectionHeaderFormatter.dateFormat = "EEEE - hh:00 a";

        timeFormatter.timeZone = NSTimeZone(name: "UTC")
        timeFormatter.dateFormat = "hh:mm a";
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

        var eventQuery = PFQuery(className:"Event")
        //eventsQuery.fromLocalDatastore()
        eventQuery.orderByAscending("startTime")
        eventQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) in
            if error != nil {
                // Log details of the failure
                println("Error: %@ %@", error, error.userInfo!)
                return
            } 
            self.events = [Event]()

            for object in objects {
                let object = object as! PFObject
                //object.pinInBackground()
                self.events.append(Event(parseReturn: object))
            }

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
        var companiesQuery = PFQuery(className: "Company")
        //sponsorsQuery.fromLocalDatastore()
        companiesQuery.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) in
            if error != nil {
                println("Error: %@ %@", error, error.userInfo!)
                return
            }
            for object in objects {
                let object = object as! PFObject
                let company = Company(parseReturn: object)
                self.companies[company.objectID] = company
            }

        })
    }

    private func createSectionedRepresentation(){
        if events.count == 0 {
            return
        }
        let calendar = NSCalendar.currentCalendar()
        let desiredComponents = (NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitDay)
        var currentSection = 0
        var comparisonIndex = 0;
        var comparisonEvent = self.events[comparisonIndex]
        var newSection = [EventReference]()
        newSection.append(EventReference(event: comparisonEvent))
        self.sections[currentSection] = newSection
        var comparisonComponents = calendar.components(desiredComponents, fromDate: comparisonEvent.startTime)
        for var i = 1; i < self.events.count; i++ {
            let currentEvent = self.events[i]

            let currentComponents = calendar.components( desiredComponents, fromDate:currentEvent.startTime)
            if comparisonComponents.hour != currentComponents.hour ||
                comparisonComponents.day != currentComponents.day {
                    currentSection++
                    var newSection = [EventReference]()
                    newSection.append(EventReference(event: currentEvent))
                    self.sections[currentSection] = newSection
                    comparisonIndex = i
                    comparisonEvent = self.events[comparisonIndex]
                    comparisonComponents = calendar.components(desiredComponents, fromDate: comparisonEvent.startTime)

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
        let eventCompany = companies[event.company.objectId]
        var thumbnail = eventCompany?.thumbnail
        if thumbnail == nil {
             thumbnail = UIImage(named: "mad_thumbnail.png")!
        }
        let eventViewController = EventViewController( event: event, company: eventCompany!, image: thumbnail!)
        
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return EVENTS_TABLEVIEW_CELL_HEIGHT
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        let sectionTime = section![0].referenced!.startTime
        return sectionHeaderFormatter.stringFromDate(sectionTime)

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(EVENTS_TABLEVIEW_CELL_IDENTIFIER, forIndexPath: indexPath) as! UITableViewCell
        let section = sections[indexPath.section]
        let event = section![indexPath.row].referenced!

        var startTimeString = "00:00"
        var endTimeString = "00:00"

        startTimeString = timeFormatter.stringFromDate(event.startTime)
        endTimeString = timeFormatter.stringFromDate(event.endTime)

        cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = "\(startTimeString) - \(endTimeString) – \(event.room)"

        cell.imageView?.image =  UIImage(named: "mad_thumbnail.png")
        if let logo = companies[event.company.objectId]?.thumbnail {
            cell.imageView?.image = logo
        }

        
        return cell
    }
}