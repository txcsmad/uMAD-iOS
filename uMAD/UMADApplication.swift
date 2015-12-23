import Foundation
import Parse

class UMADApplication: PFObject, PFSubclassing {

    @NSManaged var user: User
    @NSManaged var status: String
    @NSManaged var dietaryRestrictions: String
    @NSManaged var firstTime: Bool
    @NSManaged var arrivedAt: NSDate?

    static func parseClassName() -> String {
        return "UMAD_Application"
    }


}
