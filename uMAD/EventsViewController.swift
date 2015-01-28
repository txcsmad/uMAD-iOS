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
    private var rowsPerSection: [String: Int] = [String: Int]()
    private var sectionHeaders: [String] = [String]()
    
    override init() {
        super.init()
        
        view.backgroundColor = UIColor.lightGrayColor()
        navigationItem.title = "Events"
        
        tableView = UITableView(frame: CGRectMake(0, 0, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)), style: .Plain)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "EVENTS_TABLEVIEW_CELL_IDENTIFIER")
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        var query = PFQuery(className:"Events")
        query.findObjectsInBackgroundWithBlock {
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
                    
                    println("Time String: \(timeString) Occured: \(self.rowsPerSection[timeString])")
                    
                }
                
                self.events = self.events.sorted({
                    (firstEvent: Event, secondEvent: Event) -> Bool in
                    return firstEvent.startTime.description < secondEvent.startTime.description
                })
                
                for event in self.events {
                    println("Time: \(event.startTime)")
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    () -> Void in
                    UIView.transitionWithView(self.tableView, duration: 0.1, options: UIViewAnimationOptions.ShowHideTransitionViews, animations: {
                        () -> Void in
                        self.tableView.reloadData()
                    }, completion: nil)
                })
                
            } else {
                // Log details of the failure
                println("Error: %@ %@", error, error.userInfo!)
            }
        }
    }
    
     override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

     required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tabImage: UIImage = UIImage(named: "events.png")!
        var resizedImage: UIImage = tabImage.resizedImageToSize(CGSizeMake(25.00, 25.00))
        
        self.tabBarItem.image = resizedImage
        self.tabBarItem.title = "Events"
    }
    
    func calculateIndex(indexPath: NSIndexPath) -> Int {
        var result: Int = 0
        for (var i: Int = 0; i < indexPath.section; i++) {
            var headerString: String = self.sectionHeaders[i]
            result += self.rowsPerSection[headerString]!
        }
        
        return result
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
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.00
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeaders[section];
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var index: Int = calculateIndex(indexPath)
        
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("EVENTS_TABLEVIEW_CELL_IDENTIFIER", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = self.events[index].companyName
        
        return cell
    }
    
}