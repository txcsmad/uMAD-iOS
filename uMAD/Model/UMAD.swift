import Foundation
import Parse

class UMAD: PFObject, PFSubclassing {
    @NSManaged var year: Int

    static func parseClassName() -> String {
        return "UMAD"
    }
}
