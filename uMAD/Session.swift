import Parse

class Session: PFObject, PFSubclassing, Separable, CustomDebugStringConvertible {

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

    var topicTagsSet: Set<String> {
        return Set<String>(topicTags)
    }

    static func parseClassName() -> String {
        return "UMAD_Session"
    }

    override var debugDescription: String {
        get {
            return "\(name) \(startTime)"
        }
    }

    // MARK:- Favorites

    func addToFavorites(completion: (Bool, NSError?) -> ()) {
        incrementKey("favoriteCount")
        saveInBackground()

        let favorites = PFUser.currentUser()?.relationForKey("favorites")
        favorites?.addObject(self)
        PFUser.currentUser()?.saveInBackgroundWithBlock(completion)
    }

    func removeFromFavorites(completion: (Bool, NSError?) -> ()) {
        incrementKey("favoriteCount", byAmount: -1)
        saveInBackground()

        let favorites = PFUser.currentUser()?.relationForKey("favorites")
        favorites?.removeObject(self)
        PFUser.currentUser()?.saveInBackgroundWithBlock(completion)
    }
    
    // MARK:- Seperable

    func shouldBeSeparated(from: Session) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        return !calendar.isDate(startTime, equalToDate: from.startTime, toUnitGranularity: .Hour)
    }

}
