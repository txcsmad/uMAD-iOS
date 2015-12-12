import Foundation

class Event: PFObject, PFSubclassing, Separable {
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

    private static let desiredComponents: NSCalendarUnit = ([NSCalendarUnit.Hour, NSCalendarUnit.Day])
    private static let calendar = NSCalendar.currentCalendar()
    var topicTagsSet: Set<String> {
        get {
            return Set<String>(topicTags)
        }
    }

    static func parseClassName() -> String {
        return "Event"
    }

   func stringDescription() -> String {
        return "\(name)"
    }

    func shouldBeSeparated(from: Event) -> Bool {
        let comparisonComponents = Event.calendar.components(Event.desiredComponents, fromDate: from.startTime)
        let currentComponents = Event.calendar.components( Event.desiredComponents, fromDate:self.startTime)
        return comparisonComponents.hour != currentComponents.hour || comparisonComponents.day != currentComponents.day
    }
}