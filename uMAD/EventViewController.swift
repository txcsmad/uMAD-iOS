//
//  EventViewController.swift
//  uMAD
//
//  Created by Andrew Chun on 1/29/15.
//  Copyright (c) 2015 com.MAD. All rights reserved.
//

import Foundation

let WEBSITE_TABLEVIEW_CELL_HEIGHT: CGFloat = 44.00
let STATUS_BAR_HEGHT: CGFloat = 20.00

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var image: UIImage!
    var event: Event!
    var tableView: UITableView!
    
    override init() {
        super.init()
    }
    
    init(image: UIImage, event: Event) {
        super.init()
        
        self.event = event
        self.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Session Info"
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        var resizedImage: UIImage = image.resizedImageToSize(CGSizeMake(image.size.width * 0.35, image.size.height * 0.35))
        
        var tableHeaderView: UIView = UIView(frame: CGRectZero)
        
        //Image
        var thumbnailView: UIImageView = UIImageView(image: self.image.imageScaledToSize(CGSizeMake(75.00, 75.00)))
        thumbnailView.frame = CGRectMake(CGRectGetWidth(thumbnailView.bounds) * 0.20, CGRectGetHeight(thumbnailView.bounds) * 0.20, 75.00, 75.00)
        tableHeaderView.addSubview(thumbnailView)
        
        //Company
        var companyLabelOriginX: CGFloat = thumbnailView.frame.origin.x + thumbnailView.frame.width + 10
        var companyLabelOriginY: CGFloat = thumbnailView.frame.origin.y
        var companyLabel: UILabel = UILabel(frame: CGRectMake(companyLabelOriginX, companyLabelOriginY, CGRectGetWidth(self.view.bounds) * 0.40, CGRectGetHeight(self.view.bounds) * 0.05))
        companyLabel.font = UIFont(name: "HelveticaNeue-Bold", size: companyLabel.font.pointSize)
        companyLabel.text = self.event.companyName
        companyLabel.sizeToFit()
        tableHeaderView.addSubview(companyLabel)
        
        //Speaker
        var speakerLabelOriginX: CGFloat = thumbnailView.frame.origin.x + thumbnailView.frame.width + 10
        var speakerLabelOriginY: CGFloat = companyLabelOriginY + CGRectGetHeight(companyLabel.bounds)
        var speakerLabel: UILabel = UILabel(frame: CGRectMake(speakerLabelOriginX, speakerLabelOriginY, CGRectGetWidth(self.view.bounds) * 0.40, CGRectGetHeight(self.view.bounds) * 0.05))
        speakerLabel.text = self.event.speaker
        speakerLabel.sizeToFit()
        tableHeaderView.addSubview(speakerLabel)
        
        //Time
        let startTime: NSDate   = self.event.startTime
        let endTime: NSDate     = self.event.endTime
        
        let timeFormatter: NSDateFormatter  = NSDateFormatter()
        timeFormatter.timeZone              = NSTimeZone(name: "America/Chicago")
        timeFormatter.dateFormat            = "hh:mm a";
        let startTimeString: String         = timeFormatter.stringFromDate(startTime)
        let endTimeString: String           = timeFormatter.stringFromDate(endTime)
        
        var timeLabelOriginX: CGFloat = thumbnailView.frame.origin.x + thumbnailView.frame.width + 10
        var timeLabelOriginY: CGFloat = speakerLabelOriginY + CGRectGetHeight(speakerLabel.bounds)
        var timeLabel: UILabel = UILabel(frame: CGRectMake(timeLabelOriginX, timeLabelOriginY, CGRectGetWidth(self.view.bounds) * 0.40, CGRectGetHeight(self.view.bounds) * 0.05))
        timeLabel.text = startTimeString + " - " + endTimeString
        timeLabel.font = UIFont.systemFontOfSize(15.00)
        timeLabel.textColor = UIColor.lightGrayColor()
        timeLabel.sizeToFit()
        tableHeaderView.addSubview(timeLabel)
        
        //Room
        var roomLabelOriginX: CGFloat = thumbnailView.frame.origin.x + thumbnailView.frame.width + 10
        var roomLabelOriginY: CGFloat = timeLabelOriginY + CGRectGetHeight(timeLabel.bounds)
        var roomLabel: UILabel = UILabel(frame: CGRectMake(roomLabelOriginX, roomLabelOriginY, CGRectGetWidth(self.view.bounds) * 0.40, CGRectGetHeight(self.view.bounds) * 0.05))
        roomLabel.text = self.event.room
        roomLabel.font = UIFont.systemFontOfSize(15.00)
        roomLabel.textColor = UIColor.lightGrayColor()
        roomLabel.sizeToFit()
        tableHeaderView.addSubview(roomLabel)
        
        //Session
        var sessionLabelOriginX: CGFloat = thumbnailView.frame.origin.x
        var sessionLabelOriginY: CGFloat = thumbnailView.frame.origin.y + CGRectGetHeight(thumbnailView.bounds) + 20
        var sessionLabel: UILabel = UILabel(frame: CGRectMake(sessionLabelOriginX, sessionLabelOriginY, CGRectGetWidth(self.view.bounds) - (sessionLabelOriginX * 2.00), CGRectGetHeight(self.view.bounds) * 0.05))
        sessionLabel.font = UIFont(name: "HelveticaNeue-Bold", size: companyLabel.font.pointSize + 1.50)
        sessionLabel.text = self.event.sessionName
        sessionLabel.sizeToFit()
        tableHeaderView.addSubview(sessionLabel)
        
        //Description
        var descLabelOriginX: CGFloat = thumbnailView.frame.origin.x
        var descLabelOriginY: CGFloat = sessionLabelOriginY + CGRectGetHeight(sessionLabel.bounds) + 5
        var descLabel: UILabel = UILabel(frame: CGRectMake(descLabelOriginX, descLabelOriginY, CGRectGetWidth(self.view.bounds) - (descLabelOriginX * 2.00), CGRectGetHeight(self.view.bounds) * 0.05))
        descLabel.text = self.event.description
        descLabel.numberOfLines = 0
        descLabel.sizeToFit()
        tableHeaderView.addSubview(descLabel)
        
        tableHeaderView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), descLabelOriginY + CGRectGetHeight(descLabel.bounds) + 10)
        
        tableView = UITableView(frame: CGRectMake(0, 0, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)), style: UITableViewStyle.Grouped)
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:"WEBSITE_TABLEVIEW_CELL")
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.contentInset = UIEdgeInsetsMake(1.00, 0, 0, 0)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return WEBSITE_TABLEVIEW_CELL_HEIGHT
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var webViewController: SVWebViewController = SVWebViewController(URL: self.event.companyWebsite)
        webViewController.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("WEBSITE_TABLEVIEW_CELL", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = self.event.companyWebsite.absoluteString
        
        return cell
    }
}