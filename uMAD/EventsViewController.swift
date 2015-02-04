//
//  EventsViewController.swift
//  uMAD
//
//  Created by Andrew Chun on 1/25/15.
//  Copyright (c) 2015 com.MAD. All rights reserved.
//

import Foundation
import UIKit

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var tableView: UITableView!
    private var events: [Event] = [Event]()
    private var rowsPerSection: [String : Int] = [String : Int]()
    private var sectionHeaders: [String] = [String]()
    private var thumbnails: [String : UIImage] = [String : UIImage]()
    private var logos: [String : UIImage] = [String : UIImage]()
    
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    override init() {
        super.init()
        
        self.reloadData()
    }
    
     override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

     required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Events"
        
        self.tableView = UITableView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - TABBAR_HEIGHT), style: .Plain)
        self.tableView.registerClass(EventTableViewCell.self, forCellReuseIdentifier: "EVENTS_TABLEVIEW_CELL_IDENTIFIER")
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        view.addSubview(self.tableView)
        
        self.refreshControl.addTarget(self, action: Selector("reloadData"), forControlEvents: .ValueChanged)
        self.tableView.addSubview(self.refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func calculateIndex(indexPath: NSIndexPath) -> Int {
        var result: Int = 0
        for (var i: Int = 0; i <= indexPath.section; i++) {
            var headerString: String = self.sectionHeaders[i]
            
            if i == indexPath.section {
                result += indexPath.row
            } else {
                result += self.rowsPerSection[headerString]!
            }
        }
        
        return result
    }
    
    func monthToInt(month: String) -> Int {
        switch month {
            case "January":
                return 0
            case "February":
                return 1
            case "March":
                return 2
            case "April":
                return 3
            case "May":
                return 4
            case "June":
                return 5
            case "July":
                return 6
            case "August":
                return 7
            case "September":
                return 8
            case "October":
                return 9
            case "November":
                return 10
            case "December":
                return 11
            default:
                fatalError("Unidentifiable month string")
        }
    }
    
    func reloadData() {
        self.events = [Event]()
        self.rowsPerSection = [String : Int]()
        self.sectionHeaders = [String]()
        
        var eventsQuery: PFQuery = PFQuery(className:"Events")
        eventsQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {                
                for object in objects {
                    var info: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
                    info["sessionName"] = object["sessionName"] as String!
                    info["companyName"] = object["company"] as String!
                    info["room"] = object["room"] as String!
                    info["speaker"] = object["speaker"] as String!
                    info["description"] = object["description"] as String!
                    info["startTime"] = object["startTime"] as NSDate!
                    info["endTime"] = object["endTime"] as NSDate!
                    info["email"] = object["email"] as String!
                    info["companyWebsite"] = NSURL(string: object["companyWebsite"] as String!)!
                    info["twitterHandle"] = object["twitterHandle"] as String!
                    info["image"] = object["image"] as PFFile!
                    info["companyID"] = object["companyID"] as NSNumber!
                    
                    var event: Event = Event(info: info)
                    self.events.append(event)
                    
                    var timeFormatter: NSDateFormatter = NSDateFormatter()
                    timeFormatter.timeZone = NSTimeZone(name: "America/Chicago")
                    timeFormatter.dateFormat = "MMMM d - hh:00 a";
                    var timeString: String = timeFormatter.stringFromDate(info["startTime"] as NSDate!)
                                        
                    if self.rowsPerSection[timeString] == nil {
                        self.rowsPerSection[timeString] = 1
                    } else {
                        self.rowsPerSection[timeString]! += 1
                    }
                }
                
                self.events = self.events.sorted({
                    (firstEvent: Event, secondEvent: Event) -> Bool in
                    return firstEvent.startTime.description < secondEvent.startTime.description
                })
                
                self.sectionHeaders = []
                
                for key in self.rowsPerSection.keys {
                    self.sectionHeaders.append(key)
                }
                
                self.sectionHeaders = self.sectionHeaders.sorted({
                    (s1: String, s2: String) -> Bool in
                    let s1Array: [String] = s1.componentsSeparatedByString(" ")
                    let s2Array: [String] = s2.componentsSeparatedByString(" ")
                    
                    let s1Month: Int = self.monthToInt(s1Array[0])
                    let s2Month: Int = self.monthToInt(s2Array[0])
                    let s1Day: Int = s1Array[1].toInt()!
                    let s2Day: Int = s2Array[1].toInt()!
                    let s1Split: Int = s1Array[4] == "AM" ? 0 : 1
                    let s2Split: Int = s2Array[4] == "AM" ? 0 : 1
                    let s1Time: Int = s1Array[3].componentsSeparatedByString(":")[0].toInt()!
                    let s2Time: Int = s2Array[3].componentsSeparatedByString(":")[0].toInt()!
                    
                    if s1Month == s2Month {
                        if s1Day == s2Day {
                            if s1Split == s2Split {
                                if s1Time == 12 {
                                    return s1Time < s2Time
                                }
                                
                                return s1Time > s2Time
                            }
                            
                            return s1Split < s2Split
                        }
                        
                        return s1Day < s2Day
                    }
                    
                    return s1Month < s2Month
                })
                
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    UIView.transitionWithView(self.tableView, duration: 0.1, options: UIViewAnimationOptions.ShowHideTransitionViews, animations: {
                        () -> Void in
                        
                        let delayTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.20 * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            self.refreshControl.endRefreshing()
                        }
                        
                        self.tableView.reloadData()
                        }, completion: nil)
                })
            } else {
                // Log details of the failure
                println("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowsPerSection[self.sectionHeaders[section]]!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionHeaders.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let index: Int = calculateIndex(indexPath)
        let event: Event = self.events[index]
        let companyName: String = event.companyName
        let companyID: String = event.companyID.stringValue
        let thumbnail: UIImage = self.thumbnails[companyID] != nil ? self.thumbnails[companyID]! : UIImage(named: "mad_thumbnail.png")!
        var eventViewController: EventViewController = EventViewController(image: thumbnail, event: event)
        
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return EVENTS_TABLEVIEW_CELL_HEIGHT
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeaders[section];
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        var sectionHeaderView: UITableViewHeaderFooterView = view as UITableViewHeaderFooterView
        
        sectionHeaderView.textLabel.font = UIFont.systemFontOfSize(FONT_SIZE)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: EventTableViewCell = tableView.dequeueReusableCellWithIdentifier("EVENTS_TABLEVIEW_CELL_IDENTIFIER", forIndexPath: indexPath) as EventTableViewCell
        
        let index: Int = calculateIndex(indexPath)
        let companyName: String = self.events[index].companyName
        let sessionName: String = self.events[index].sessionName
        let startTime: NSDate   = self.events[index].startTime
        let endTime: NSDate     = self.events[index].endTime
        let room: String        = self.events[index].room
        let companyIDNumber: NSNumber = self.events[index].companyID
        let companyIDString: String = self.events[index].companyID.stringValue
        
        let timeFormatter: NSDateFormatter  = NSDateFormatter()
        timeFormatter.timeZone              = NSTimeZone(name: "America/Chicago")
        timeFormatter.dateFormat            = "hh:mm a";
        let startTimeString: String         = timeFormatter.stringFromDate(startTime)
        let endTimeString: String           = timeFormatter.stringFromDate(endTime)
        
        
        cell.textLabel?.font = UIFont.systemFontOfSize(FONT_SIZE)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(DETAIL_FONT_SIZE)
        
        cell.textLabel?.text        = companyName
        cell.detailTextLabel?.text  = sessionName
        cell.timeLabel?.text        = startTimeString + " - " + endTimeString
        cell.locationLabel?.text    = room
        cell.imageView?.image       = self.thumbnails[companyIDString] != nil ? self.thumbnails[companyIDString]?.imageScaledToSize(CGSizeMake(50, 50)) : UIImage(named: "mad_thumbnail.png")?.imageScaledToSize(CGSizeMake(50, 50))
        
        var sponsorsQuery: PFQuery = PFQuery(className: "Sponsors")
        sponsorsQuery.whereKey("identifierNumber", equalTo: companyIDNumber)
        sponsorsQuery.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects {
                    var companyName: String = object["companyName"] as String!
                    var companyIDString: String = (object["identifierNumber"] as NSNumber!).stringValue
                    
                    if self.logos[companyIDString] == nil {
                        var parseImage: PFFile = object["companyImage"] as PFFile!
                        parseImage.getDataInBackgroundWithBlock({
                            (data: NSData!, error: NSError!) -> Void in
                            self.logos[companyIDString] = UIImage(data: data)!
                        })
                    }
                    
                    if self.thumbnails[companyIDString] == nil || cell.imageView?.image != self.thumbnails[companyIDString] {
                        var parseThumbnail: PFFile = object["thumbnail"] as PFFile!
                        parseThumbnail.getDataInBackgroundWithBlock({
                            (data: NSData!, error: NSError!) -> Void in
                            self.thumbnails[companyIDString] = UIImage(data: data)!
                            cell.imageView?.image = self.thumbnails[companyIDString]?.imageScaledToSize(CGSizeMake(50.00, 50.00))
                        })
                    }
                }
                
            } else {
                // Log details of the failure
                println("Error: %@ %@", error, error.userInfo!)
            }
        })
        return cell
    }
    
}