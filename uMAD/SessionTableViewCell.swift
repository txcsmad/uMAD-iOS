import UIKit
import ParseUI

class SessionTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .DisclosureIndicator
        layoutMargins = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false
    }

    required convenience init?(coder: NSCoder) {
        self.init(style: .Subtitle, reuseIdentifier: "")
    }
    
    func configureForSession(session: Session) {
        textLabel?.text = session.name
        
        let startTime = NSDateFormatter.localizedStringFromDate(session.startTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        let endTime = NSDateFormatter.localizedStringFromDate(session.endTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        let time = NSMutableAttributedString(string: "\(startTime) - \(endTime)\n")
        
        let room = NSAttributedString(string: session.room, attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        time.appendAttributedString(room)
        detailTextLabel?.attributedText = time
        detailTextLabel?.numberOfLines = 0
        
        imageView?.image = UIImage(named: "event_logo")
        session.company?.thumbnail?.getDataInBackgroundWithBlock { data, _ in
            guard let imageData = data else {
                return
            }
            self.imageView?.image = UIImage(data: imageData)
        }
    }

}
