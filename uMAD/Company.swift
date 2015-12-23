import Parse

class Company: PFObject, PFSubclassing {

    @NSManaged var name: String
    @NSManaged var sponsorLevel: Int
    @NSManaged var website: String
    @NSManaged var twitterHandle: String
    @NSManaged var image: PFFile
    @NSManaged var thumbnail: PFFile?
    var websiteURL: NSURL {
        return NSURL(string: website)!
    }

    static func parseClassName() -> String {
        return "Company"
    }

}
