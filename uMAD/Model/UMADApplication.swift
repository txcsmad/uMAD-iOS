import Foundation
import Parse

class UMADApplication: PFObject, PFSubclassing {

    @NSManaged var user: User
    @NSManaged var dietaryRestrictions: String
    @NSManaged var firstTime: Bool

    static func parseClassName() -> String {
        return "UMAD_Application"
    }

    static func fetchApplication(user: User, completion: (UMADApplication?, NSError?) -> ()) {
        guard let currentUMAD = AppDelegate.currentUMAD else {
            completion(nil, nil)
            return
        }
        let statusQuery = UMADApplication.query()
        statusQuery?.whereKey("user", equalTo: user)
        statusQuery?.whereKey("umad", equalTo: currentUMAD)
        statusQuery?.findObjectsInBackgroundWithBlock({ (result, err) -> Void in
            guard let application = result?.first as? UMADApplication else {
                // No application, or query invalid
                completion(nil, nil)
                return
            }
            guard result?.count == 1 else {
                // More than one application
                completion(nil, nil)
                return
            }
            completion(application, nil)
        })
    }

    /**
     Convenience for fetching the current user's application for the current UMAD

     - parameter completion: the completion handler
     */
    static func fetchApplication(completion: (UMADApplication?, NSError?) -> ()) {
        guard let currentUser = User.currentUser() else {
            completion(nil, nil)
            return
        }
        fetchApplication(currentUser, completion: completion)
    }

}
