import UIKit
import ParseUI

class SessionTableViewCell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var timeLabel: Label!
    @IBOutlet weak var locationLabel: Label!
    @IBOutlet weak var favoritedImageView: ImageView!
    @IBOutlet weak var capacityIndicator: UIView!

    func configureForSession(session: Session) {
        titleLabel.text = session.name

        let startTime = NSDateFormatter.localizedStringFromDate(session.startTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        let endTime = NSDateFormatter.localizedStringFromDate(session.endTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        timeLabel.text = "\(startTime) - \(endTime)"

        if !session.room.isEmpty {
            locationLabel.text = " - \(session.room)"
        } else {
            locationLabel.text = ""
        }

        logoImageView.image = UIImage(named: "event_logo")
        session.company?.thumbnail?.getDataInBackgroundWithBlock { data, _ in
            guard let imageData = data else {
                return
            }
            self.logoImageView.image = UIImage(data: imageData)
        }

        favoritedImageView.alpha = 0
        favoritedImageView.alpha = session.isFavorited() ? 1.0 : 0.0

        capacityIndicator.alpha = session.atCapacity ? 1.0 : 0.0
    }

}
