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

        if wouldCreateNewOverlapWith(user.favorites!) != nil {
            completion(false, nil)
            return
        }


        // Update user relation
        let favorites = user.relationForKey("favorites")
        favorites.addObject(self)

        user.saveInBackgroundWithBlock { success, error in
            if success {
                // Update session fav count
                self.incrementKey("favoriteCount")
                self.saveInBackground()

                // Subscribe to new notifications
                let installation = PFInstallation.currentInstallation()
                installation.addUniqueObject("session" + self.objectId!, forKey: "channels")
                installation.saveInBackground()

                // Add the session to the local store
                user.favorites?.insert(self)
                user.postFavoritesDidChange()

            }
            completion(success, error)
        }
    }

    func removeFromFavorites(completion: (Bool, NSError?) -> ()) {
        guard let user = User.currentUser()
            where user.favorites != nil && user.favorites!.contains(self) == true else {
            return
        }

        // Update relation
        let favorites = user.relationForKey("favorites")
        favorites.removeObject(self)

        user.saveInBackgroundWithBlock { success, error in
            if success {
                // Update the session favCount
                self.incrementKey("favoriteCount", byAmount: -1)
                self.saveInBackground()

                // Add to local store
                user.favorites?.remove(self)
                user.postFavoritesDidChange()

                // Unsubscribe from push channels
                let installation = PFInstallation.currentInstallation()
                installation.removeObjectsInArray(["session" + self.objectId!], forKey: "channels")
                installation.saveInBackground()
            }
            completion(success, error)
        }


    }

    func isFavorited() -> Bool {
        guard let user = User.currentUser(),
           let localFavs = user.favorites else {
            return false
        }
        return localFavs.contains(self)
    }


    //MARK:- Overlap detection

    /**
    Detect if adding self to a set of sessions would create a new overlap that
    isn't already present

    - parameter sessions: a set of sessions

    - returns: the first session that the added session would conflict with, or nil if none
    */
    func wouldCreateNewOverlapWith(sessions: Set<Session>) -> Session? {
        // If the set already contains the session, we can't create a new conflict
        if sessions.contains(self) {
            return nil
        }
        var sessionsCopy = sessions
        sessionsCopy.insert(self)
        if let (firstOverlap, secondOverlap) = sessionsOverlap(sessionsCopy) {
            // Return the session that _isn't_ the one that was passed in
            return firstOverlap == self ? secondOverlap : firstOverlap
        } else {
            return nil
        }

    }

    /**
     Detect if any sessions overlap

     - parameter sessions: a set of sessions

     - returns: the first overlap (chronologically), or nil if there are no overlaps
     */
    private func sessionsOverlap(sessions: Set<Session>) -> (Session, Session)? {
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
                return (first, second)
            }
        }
        return nil
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

    override var hashValue: Int {
        return objectId!.hashValue
    }


}
