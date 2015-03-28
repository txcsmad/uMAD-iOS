import Foundation

class Event: NSObject {
    let name: String
    let room: String
    let speaker: String
    let descriptionText: String
    let startTime: NSDate
    let endTime: NSDate
    let email: String
    let objectID: String
    let topicTags: [String]
    let company: PFObject
    
    init(parseReturn: PFObject) {
        name = parseReturn["name"] as! String
        room = parseReturn["room"] as! String
        speaker = parseReturn["speaker"] as! String
        descriptionText = parseReturn["description"] as! String
        startTime = parseReturn["startTime"] as! NSDate
        endTime = parseReturn["endTime"] as! NSDate
        email = parseReturn["email"] as! String
        objectID = parseReturn.objectId!
        topicTags = parseReturn["topicTags"] as! [String]
        company = parseReturn["company"] as! PFObject
        
    }

   func stringDescription() -> String {
        return "\(name)"
    }

}