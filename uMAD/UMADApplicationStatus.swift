import Foundation
import Parse

class UMADApplicationStatus: PFObject, PFSubclassing {

    @NSManaged var status: String
    @NSManaged var application: UMADApplication
    @NSManaged var arrivedAt: NSDate?

    static func parseClassName() -> String {
        return "UMAD_Application_Status"
    }


}
