import Parse

class Session: PFObject, PFSubclassing, Separable, CustomDebugStringConvertible {

    @NSManaged var bio: String?
    @NSManaged var capacity: NSNumber?
    @NSManaged var favoriteCount: Int
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

    var atCapacity: Bool {
        if let capacity = capacity as? Int
            where favoriteCount > capacity {
                return true
        } else {
            return false
        }
    }

    // MARK:- Favorites

    func addToFavorites(completion: (Bool, NSError?) -> ()) {
        guard let user = User.currentUser()
           where user.favorites != nil && user.favorites!.contains(self) == false else {
            completion(false, nil)
            return
        }

        user.favorites?.insert(self)

        if sessionsOverlap(user.favorites!) {
            user.favorites?.remove(self)
            completion(false, nil)
            return
        }
        user.postFavoritesDidChange()

        incrementKey("favoriteCount")
        saveInBackground()


        let favorites = user.relationForKey("favorites")
        favorites.addObject(self)
        user.saveInBackgroundWithBlock(completion)
    }

    func removeFromFavorites(completion: (Bool, NSError?) -> ()) {
        guard let user = User.currentUser()
            where user.favorites != nil && user.favorites!.contains(self) == true else {
            return
        }
        incrementKey("favoriteCount", byAmount: -1)
        saveInBackground()

        let favorites = user.relationForKey("favorites")
        favorites.removeObject(self)
        user.saveInBackgroundWithBlock(completion)
        user.favorites?.remove(self)
        user.postFavoritesDidChange()
    }

    func isFavorited() -> Bool {
        guard let user = User.currentUser(),
           let localFavs = user.favorites else {
            return false
        }
        return localFavs.contains(self)
    }

    private func sessionsOverlap(sessions: Set<Session>) -> Bool {
        let chronologicalFavs = sessions.sort { $0.0.startTime.compare($0.1.startTime) == .OrderedAscending  }

        var i = 0
        var j = 1
        // Check every pair for overlap
        while i <= chronologicalFavs.count - 2 && j <= chronologicalFavs.count - 1 {
            let first = chronologicalFavs[i]
            let second = chronologicalFavs[j]

            let comparison = first.endTime.compare(second.startTime)
            // Is the starttime before/equal to the end time of the event after it?
            if comparison == .OrderedAscending || comparison == .OrderedSame {
                i++
                j++
            } else {
                return true
            }
        }
        return false
    }
    // MARK:- Seperable

    func shouldBeSeparated(from: Session) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        return !calendar.isDate(startTime, equalToDate: from.startTime, toUnitGranularity: .Hour)
    }

    override func isEqual(object: AnyObject?) -> Bool {
        if let second = object as? Session {
            return self.objectId == second.objectId
        } else {
            return false
        }
    }

}
