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
        
        tableView = UITableView(frame: CGRectMake(0, 0, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)), style: .Plain)
        tableView.registerClass(EventTableViewCell.self, forCellReuseIdentifier: "EVENTS_TABLEVIEW_CELL_IDENTIFIER")
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        refreshControl.addTarget(self, action: Selector("reloadData"), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
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
    
    func reloadData() {
        events = [Event]()
        rowsPerSection = [String : Int]()
        sectionHeaders = [String]()
        
        var eventsQuery: PFQuery = PFQuery(className:"Events")
        eventsQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects.count) events.")
                // Do something with the found objects
                
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
                
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    UIView.transitionWithView(self.tableView, duration: 0.1, options: UIViewAnimationOptions.ShowHideTransitionViews, animations: {
                        () -> Void in
                        self.refreshControl.endRefreshing()
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
        self.sectionHeaders = []
        
        for key in self.rowsPerSection.keys {
            self.sectionHeaders.append(key)
        }
        
        self.sectionHeaders = self.sectionHeaders.sorted({
            (s1: String, s2: String) -> Bool in
            return s1 < s2
        })
        
        return self.sectionHeaders.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let index: Int = calculateIndex(indexPath)
        let event: Event = self.events[index]
        let companyName: String = event.companyName
        let thumbnail: UIImage = self.thumbnails[companyName] != nil ? self.thumbnails[companyName]! : UIImage(named: "mad_thumbnail.png")!
        var eventViewController: EventViewController = EventViewController(image: thumbnail, event: event)
        
        self.navigationController?.pushViewController(eventViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return EVENTS_TABLEVIEW_CELL_HEIGHT
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeaders[section];
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: EventTableViewCell = tableView.dequeueReusableCellWithIdentifier("EVENTS_TABLEVIEW_CELL_IDENTIFIER", forIndexPath: indexPath) as EventTableViewCell
        
        let index: Int = calculateIndex(indexPath)
        let companyName: String = self.events[index].companyName
        let sessionName: String = self.events[index].sessionName
        let startTime: NSDate   = self.events[index].startTime
        let endTime: NSDate     = self.events[index].endTime
        let room: String        = self.events[index].room
        
        let timeFormatter: NSDateFormatter  = NSDateFormatter()
        timeFormatter.timeZone              = NSTimeZone(name: "America/Chicago")
        timeFormatter.dateFormat            = "hh:mm a";
        let startTimeString: String         = timeFormatter.stringFromDate(startTime)
        let endTimeString: String           = timeFormatter.stringFromDate(endTime)
        
        
        cell.textLabel?.text        = companyName
        cell.detailTextLabel?.text  = sessionName
        cell.timeLabel?.text        = startTimeString + " - " + endTimeString
        cell.locationLabel?.text    = room
        cell.imageView?.image       = self.thumbnails[companyName] != nil ? self.thumbnails[companyName]?.imageScaledToSize(CGSizeMake(50, 50)) : UIImage(named: "mad_thumbnail.png")?.imageScaledToSize(CGSizeMake(50, 50))
        
        var sponsorsQuery: PFQuery = PFQuery(className: "Sponsors")
        sponsorsQuery.whereKey("companyName", equalTo: companyName)
        sponsorsQuery.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects.count) sponsors.")
                // Do something with the found objects
                
                for object in objects {
                    var companyName: String = object["companyName"] as String!
                    
                    if self.logos[companyName] == nil {
                        var parseImage: PFFile = object["companyImage"] as PFFile!
                        parseImage.getDataInBackgroundWithBlock({
                            (data: NSData!, error: NSError!) -> Void in
                            self.logos[companyName] = UIImage(data: data)!
                            println("Downloaded LOGO of \(companyName)")
                        })
                    }
                    
                    if self.thumbnails[companyName] == nil {
                        var parseThumbnail: PFFile = object["thumbnail"] as PFFile!
                        parseThumbnail.getDataInBackgroundWithBlock({
                            (data: NSData!, error: NSError!) -> Void in
                            self.thumbnails[companyName] = UIImage(data: data)!
                            println("Downloaded THUMBNAIL of \(companyName)")
                            cell.imageView?.image = self.thumbnails[companyName]?.imageScaledToSize(CGSizeMake(50.00, 50.00))
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