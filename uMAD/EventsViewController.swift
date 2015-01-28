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
    
    override init() {
        super.init()
        
        view.backgroundColor = UIColor.lightGrayColor()
        
        tableView = UITableView(frame: CGRectMake(0, 20.00, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)), style: .Plain)
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
                }
                
                self.events = self.events.sorted({
                    (firstEvent: Event, secondEvent: Event) -> Bool in
                    return firstEvent.startTime.description < secondEvent.startTime.description
                })
                
                for event in self.events {
                    println("Time: \(event.startTime)")
                }
                
                self.tableView.reloadData()
                
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionNum
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.00
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(section):00";
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}