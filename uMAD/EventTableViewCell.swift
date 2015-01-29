//
//  EventTableViewCell.swift
//  uMAD
//
//  Created by Andrew Chun on 1/28/15.
//  Copyright (c) 2015 com.MAD. All rights reserved.
//

import Foundation

class EventTableViewCell: UITableViewCell {
    var timeLabel: UILabel!
    var locationLabel: UILabel!
    var eventName: UILabel!
    
    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
        
        let contentViewWidth: CGFloat = CGRectGetWidth(UIScreen.mainScreen().bounds)
        let contentViewHeight: CGFloat = EVENTS_TABLEVIEW_CELL_HEIGHT
        
        let timeLabelWidth: CGFloat = 105.00
        let timeLabelHeight: CGFloat = 15.00
        
        let locationLabelWidth: CGFloat = 57.50
        let locationLabelHeight: CGFloat = 15.00
        
        timeLabel = UILabel(frame: CGRectMake(contentViewWidth - timeLabelWidth, contentViewHeight - timeLabelHeight, timeLabelWidth, timeLabelHeight))
        timeLabel.font = UIFont.systemFontOfSize(10.00)
        timeLabel.textColor = UIColor.lightGrayColor()
        self.contentView.addSubview(timeLabel)
        
        locationLabel = UILabel(frame: CGRectMake(contentViewWidth - locationLabelWidth, 0, locationLabelWidth, locationLabelHeight))
        locationLabel.font = UIFont.systemFontOfSize(10.00)
        locationLabel.textColor = UIColor.lightGrayColor()
        self.contentView.addSubview(locationLabel)
        
        println(locationLabel.frame.origin.x + locationLabel.bounds.size.width)
        println(timeLabel.frame.origin.x + timeLabel.bounds.size.width)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}