import Foundation

class EventHeaderView: UITableViewCell {
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var speakerName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var sessionDescription: UILabel!
    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var sessionThumbnail: PFImageView!
    
    func configure(event: Event){
        event.company.fetchIfNeededInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
            self.sessionThumbnail.file = event.company.thumbnail
            self.companyName.text = event.company.name
            self.sessionThumbnail.loadInBackground({ (image, error) -> Void in
                self.setNeedsDisplay()
            })
        }

        room.text = event.room
        speakerName.text = event.speaker
        sessionDescription.text = event.descriptionText
        sessionName.text = event.name
        layoutSubviews()

        let timeFormatter  = NSDateFormatter()
        timeFormatter.timeZone = NSTimeZone(name: "UTC")
        timeFormatter.dateFormat = "hh:mm a"

        let startTimeString = timeFormatter.stringFromDate(event.startTime)
        let endTimeString = timeFormatter.stringFromDate(event.endTime)

        time.text = startTimeString + " - " + endTimeString
    }

    override func awakeFromNib() {
    }
}