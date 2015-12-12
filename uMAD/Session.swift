
import Parse

class Session: PFObject, PFSubclassing, Separable {
    
    @NSManaged var bio: String
    @NSManaged var capacity: Int
    @NSManaged var company: Company?
    @NSManaged var descriptionText: String
    @NSManaged var email: String
    @NSManaged var endTime: NSDate
    @NSManaged var name: String
    @NSManaged var room: String
    @NSManaged var speaker: String
    @NSManaged var startTime: NSDate
    @NSManaged var topicTags: [String]
    
    static func parseClassName() -> String {
        return "UMAD_Session"
    }

    func shouldBeSeparated(from: Session) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        return calendar.isDate(startTime, equalToDate: from.startTime, toUnitGranularity: .Hour)
    }
    
}
