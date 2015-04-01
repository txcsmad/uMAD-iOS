import Foundation


class Company: PFObject, PFSubclassing {
    @NSManaged var name: String
    @NSManaged var sponsorLevel: Int
    @NSManaged var website: String
    @NSManaged var twitterHandle: String
    @NSManaged var objectID: String
    @NSManaged var image: PFFile
    @NSManaged var thumbnail: PFFile

    var websiteURL:NSURL {
        get{
            return NSURL(string: website)!
        }
    }
    
    static func parseClassName() -> String {
        return "Company"
    }
   func stringDescription() -> String {
        return "\(name)"
    }



}