//
//  Event.swift
//  uMAD
//
//  Created by Andrew Chun on 1/26/15.
//  Copyright (c) 2015 com.MAD. All rights reserved.
//

import Foundation

class Event {
    var sessionName:    String!
    var companyName:    String!
    var room:           String!
    var image:          PFFile!
    var speaker:        String!
    var description:    String!
    var startTime:      NSDate!
    var endTime:        NSDate!
    var email:          String!
    var companyWebsite: NSURL!
    var twitterHandle:  String!
    
    init(info: Dictionary<String, AnyObject>) {
        sessionName = info["sessionName"]       as String!
        companyName = info["companyName"]       as String!
        room = info["room"]                     as String!
        image = info["image"]                   as PFFile!
        speaker = info["speaker"]               as String!
        description = info["description"]       as String!
        startTime = info["startTime"]           as NSDate!
        endTime = info["endTime"]               as NSDate!
        email = info["email"]                   as String!
        companyWebsite = info["companyWebsite"] as NSURL!
        twitterHandle = info["twitterHandle"]   as String!
        
    }
}