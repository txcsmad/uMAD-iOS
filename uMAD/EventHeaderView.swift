import Foundation

class EventHeaderView: UIView {
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var speakerName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var sessionDescription: UILabel!
    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var sessionThumbnail: UIImageView!
    
    func configureFromEvent(event: Event){
        companyName.text = event.companyName
        room.text = event.room
        speakerName.text = event.speaker
        sessionDescription.text = event.descriptionText
        sessionName.text = event.sessionName

        let timeFormatter  = NSDateFormatter()
        timeFormatter.timeZone = NSTimeZone(name: "UTC")
        timeFormatter.dateFormat            = "hh:mm a";
        var startTimeString: String        = "00:00"
        var endTimeString: String          = "00:00"

        if let time = event.startTime {
            startTimeString = timeFormatter.stringFromDate(time)
        }

        if let time = event.endTime {
            endTimeString = timeFormatter.stringFromDate(time)
        }

        time.text = startTimeString + " - " + endTimeString

    }
    override func awakeFromNib() {
    }
}