import Foundation

class Event: NSObject {
    var sessionName:    String?
    var companyName:    String?
    var room:           String?
    var image:          PFFile?
    var speaker:        String?
    var descriptionText:    String?
    var startTime:      NSDate?
    var endTime:        NSDate?
    var email:          String?
    var companyWebsite: NSURL?
    var companyID:      Int?
    
    init(info: Dictionary<String, AnyObject>) {
        sessionName = info["sessionName"]       as! String?
        companyName = info["companyName"]       as! String?
        room = info["room"]                     as! String?
        image = info["image"]                   as! PFFile?
        speaker = info["speaker"]               as! String?
        descriptionText = info["description"]       as! String?
        startTime = info["startTime"]           as! NSDate?
        endTime = info["endTime"]               as! NSDate?
        email = info["email"]                   as! String?
        companyWebsite = info["companyWebsite"] as! NSURL?
        companyID = info["companyID"]           as! Int?
        
    }

    convenience init(parseReturn: AnyObject){
        var info: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()

        if let sessionName: String = parseReturn["sessionName"] as? String {
            info["sessionName"] = sessionName
        }

        if let companyName: String = parseReturn["company"] as? String {
            info["companyName"] = companyName
        }

        if let room: String = parseReturn["room"] as? String {
            info["room"] = room
        }

        if let speaker: String = parseReturn["speaker"] as? String {
            info["speaker"] = speaker
        }

        if let description: String = parseReturn["description"] as? String {
            info["description"] = description
        }

        if let startTime: NSDate = parseReturn["startTime"] as? NSDate {
            info["startTime"] = startTime

        }

        if let endTime: NSDate = parseReturn["endTime"] as? NSDate {
            info["endTime"] = endTime
        }

        if let email: String = parseReturn["email"] as? String {
            info["email"] = email
        }

        if let companyWebsite: NSURL = NSURL(string: parseReturn["companyWebsite"] as! String) {
            info["companyWebsite"] = companyWebsite
        }

        if let image: PFFile = parseReturn["image"] as? PFFile {
            info["image"] = image
        }

        if let companyID: NSNumber = parseReturn["companyID"] as? Int {
            info["companyID"] = companyID
        }

        self.init(info: info)
    }

   func stringDescription() -> String {
        return "\(sessionName)\n \(companyName)"
    }

}