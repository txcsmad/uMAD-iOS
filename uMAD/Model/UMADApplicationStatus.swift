import Foundation
import Parse

class UMADApplicationStatus: PFObject, PFSubclassing {

    @NSManaged var status: String
    @NSManaged var application: UMADApplication
    @NSManaged var arrivedAt: NSDate?

    static func parseClassName() -> String {
        return "UMAD_Application_Status"
    }

    static func fetchApplicationStatusWithUser(user: User, completion: (UMADApplicationStatus?, NSError?) -> ()) {
        UMADApplication.fetchApplication(user) {  application, error in
            guard let application = application else {
                completion(nil, error)
                return
            }   
            UMADApplicationStatus.fetchApplicationStatus(application) { status, error in
                completion(status, error)
            }
        }
    }

    static func fetchApplicationStatus(application: UMADApplication, completion: (UMADApplicationStatus?, NSError?) -> ()) {
        let query = UMADApplicationStatus.query()
        query?.whereKey("application", equalTo: application)
        query?.findObjectsInBackgroundWithBlock({ (result, err) -> Void in
            guard let status = result?.first as? UMADApplicationStatus else {
                // No status. This is a serious error
                print("No status for application!")
                completion(nil, nil)
                return
            }

            completion(status, nil)
        })
    }
}
