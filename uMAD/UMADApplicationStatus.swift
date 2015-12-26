import Foundation
import Parse

class UMADApplicationStatus: PFObject, PFSubclassing {

    @NSManaged var status: String
    @NSManaged var application: UMADApplication
    @NSManaged var arrivedAt: NSDate?

    static func parseClassName() -> String {
        return "UMAD_Application_Status"
    }

    static func fetchApplicationStatusWithUser(user: User, success: (UMADApplicationStatus) -> (), error: (String) -> ()){
        UMADApplication.fetchApplication(user, success: { (application) -> () in
            fetchApplicationStatus(application, success: success, error: error)
            }) { () -> () in
                error("")
        }
    }

    static func fetchApplicationStatus(application: UMADApplication, success: (UMADApplicationStatus) -> (), error: (String) -> ()) {
        let query = UMADApplicationStatus.query()
        query?.whereKey("application", equalTo: application)
        query?.findObjectsInBackgroundWithBlock({ (result, err) -> Void in
            guard let status = result?.first as? UMADApplicationStatus else {
                // No status. This is a serious error
                print("No status for application!")
                error("Something went wrong")
                return
            }

            success(status)
        })
    }
}
