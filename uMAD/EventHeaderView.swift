import Foundation
import Parse
import ParseUI

class EventHeaderView: UITableViewCell {
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var speakerName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var sessionDescription: UILabel!
    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var sessionThumbnail: PFImageView!

    func configure(event: Session) {
        event.company?.fetchIfNeededInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
            self.sessionThumbnail.file = event.company?.thumbnail
            self.companyName.text = event.company?.name
            self.sessionThumbnail.loadInBackground({ (image, error) -> Void in
                self.setNeedsDisplay()
            })
        }

        room.text = event.room
        speakerName.text = event.speaker
        sessionDescription.text = event.descriptionText
        sessionName.text = event.name
        layoutSubviews()

        let startTimeString = NSDateFormatter.localizedStringFromDate(event.startTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        let endTimeString = NSDateFormatter.localizedStringFromDate(event.endTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)

        time.text = startTimeString + " - " + endTimeString
    }

    override func awakeFromNib() {
    }
}
