import Foundation
import Parse

class UMADApplication: PFObject, PFSubclassing {

    @NSManaged var user: User
    @NSManaged var dietaryRestrictions: String
    @NSManaged var firstTime: Bool

    static func parseClassName() -> String {
        return "UMAD_Application"
    }


}
