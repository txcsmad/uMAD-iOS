import UIKit
import ParseUI

class SessionTableViewCell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var notificationLabel: Label!
    @IBOutlet weak var timeLabel: Label!
    @IBOutlet weak var locationLabel: Label!
    @IBOutlet weak var favoritedImageView: ImageView!

    func configureForSession(session: Session) {
        titleLabel.text = session.name
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a"
        timeLabel.text = "\(formatter.stringFromDate(session.startTime)) - \(formatter.stringFromDate(session.endTime))"
        
        if !session.room.isEmpty {
            locationLabel.text = " - \(session.room)"
        } else {
            locationLabel.text = ""
        }
        
        notificationLabel.text = ""

        logoImageView.image = UIImage(named: "event_logo")
        session.company?.thumbnail?.getDataInBackgroundWithBlock { data, _ in
            guard let imageData = data else {
                return
            }
            self.logoImageView.image = UIImage(data: imageData)
        }
        
        //TODO: Turn on if the cell is favorited
        favoritedImageView.alpha = 0
    }

}
