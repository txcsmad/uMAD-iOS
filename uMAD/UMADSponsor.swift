import Parse

class UMADSponsor: PFObject, PFSubclassing {

    @NSManaged var company: Company
    @NSManaged var umad: UMAD
    @NSManaged var level: String

    static func parseClassName() -> String {
        return "UMAD_Sponsor"
    }

}
