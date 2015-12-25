import Foundation
import Parse

class UMADApplication: PFObject, PFSubclassing {

    @NSManaged var user: User
    @NSManaged var dietaryRestrictions: String
    @NSManaged var firstTime: Bool

    static func parseClassName() -> String {
        return "UMAD_Application"
    }

    static func fetchApplication(success: (UMADApplication) -> (), error: () -> ()) {
        guard let currentUser = User.currentUser(),
            let currentUMAD = AppDelegate.currentUMAD else {
                error()
                return
        }

        let statusQuery = UMADApplication.query()
        statusQuery?.whereKey("user", equalTo: currentUser)
        statusQuery?.whereKey("umad", equalTo: currentUMAD)
        statusQuery?.findObjectsInBackgroundWithBlock({ (result, err) -> Void in
            guard let application = result?.first as? UMADApplication else {
                // No application, or query invalid
                error()
                return
            }
            guard result?.count == 1 else {
                // More than one application
                error()
                return
            }
            success(application)
        })
    }

}
