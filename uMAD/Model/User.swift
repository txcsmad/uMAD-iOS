import Parse

class User: PFUser {
    @NSManaged var gender: String?
    @NSManaged var graduationYear: NSNumber?
    @NSManaged var resume: PFFile?
    @NSManaged var shirtSize: String?
    @NSManaged var major: String?
    @NSManaged var githubUsername: String?
    @NSManaged var name: String

    var favorites: Set<Session>?

    private let volunteerRole = "UMAD Volunteer"
    private var roles: [String]?

    func currentUser() -> User? {
        return PFUser.currentUser() as? User
    }

    func checkIfIsVolunteer(callback: (Bool) -> ()) {
        if let roles = self.roles {
            callback(roles.contains(volunteerRole))
            return
        }
        let query = PFRole.query()!
        query.whereKey("name", equalTo: volunteerRole)
        query.whereKey("users", equalTo: self)
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            guard let roles = results as? [PFRole] else {
                return
            }
            self.roles = [String]()
            for role in roles {
                self.roles!.append(role.name)
            }
            // Try the function again
            self.checkIfIsVolunteer(callback)
        }

    }

    func fetchFavoritesWithCompletion(completion: (Set<Session>, NSError?) -> ()) {
        let favoritesQuery = relationForKey("favorites").query()
        // Will hit the cache first for quick results. Techinically could be invalid, but not very likely.
        favoritesQuery.cachePolicy = .CacheThenNetwork
        favoritesQuery.findObjectsInBackgroundWithBlock { objects, error in
            guard let favorites = objects as? [Session] else {
                completion([], error)
                return
            }
            let favSet =  Set<Session>(favorites)
            // Detect duplicates and remove all if they occur

            if favSet.count != favorites.count {
                let favoritesRelation = User.currentUser()!.relationForKey("favorites")
                for fav in favorites {
                    favoritesRelation.removeObject(fav)
                }
                User.currentUser()!.saveInBackground()
                completion([], nil)
            } else {
                self.favorites = favSet
                completion(favSet, nil)
            }

        }
    }

    func postFavoritesDidChange() {
        NSNotificationCenter.defaultCenter().postNotificationName("favoritesDidChange", object: nil)
    }

}
