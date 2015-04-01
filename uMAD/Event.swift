import Foundation

class Event: PFObject, PFSubclassing {
    @NSManaged var name: String
    @NSManaged var room: String
    @NSManaged var speaker: String
    @NSManaged var descriptionText: String
    @NSManaged var startTime: NSDate
    @NSManaged var endTime: NSDate
    @NSManaged var email: String
    @NSManaged var objectID: String
    @NSManaged var topicTags: [String]
    @NSManaged var company: Company


    static func parseClassName() -> String {
        return "Event"
    }

   func stringDescription() -> String {
        return "\(name)"
    }

}