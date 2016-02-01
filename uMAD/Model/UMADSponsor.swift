import Parse

public class UMADSponsor: PFObject, PFSubclassing, Separable {

    @NSManaged var company: Company
    @NSManaged var umad: UMAD
    @NSManaged var level: String

    public enum Level: String {
        case Gold = "gold"
        case Silver = "silver"
        case Bronze = "bronze"

        var intValue: Int {
            switch self {
                case .Gold:
                return 3
                case .Silver:
                return 2
                case .Bronze:
                return 1
            }
        }
    }

    var sponsorLevel: Level {
        return Level(rawValue: level)!
    }

    public static func parseClassName() -> String {
        return "UMAD_Sponsor"
    }

    func shouldBeSeparated(from: UMADSponsor) -> Bool {
        return from.sponsorLevel != sponsorLevel
    }

    // MARK:- Debugging 

    public override var description: String {
        return company.name + " " + level
    }
    
    public override var debugDescription: String {
        return description
    }

}

public func < (lhs: UMADSponsor.Level, rhs: UMADSponsor.Level) -> Bool {
    return lhs.intValue < rhs.intValue
}
