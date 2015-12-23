import Parse

class User: PFUser {
    @NSManaged var gender: String?
    @NSManaged var graduationYear: NSNumber?
    @NSManaged var resume: PFFile?
    @NSManaged var shirtSize: String?
    @NSManaged var major: String?
    @NSManaged var githubUsername: String?
    @NSManaged var name: String

    func currentUser() -> User? {
        return PFUser.currentUser() as? User
    }

}
