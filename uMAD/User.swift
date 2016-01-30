import Parse

class User: PFUser {
    @NSManaged var gender: String?
    @NSManaged var graduationYear: NSNumber?
    @NSManaged var resume: PFFile?
    @NSManaged var shirtSize: String?
    @NSManaged var major: String?
    @NSManaged var githubUsername: String?
    @NSManaged var name: String

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

}
