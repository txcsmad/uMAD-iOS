import Foundation

class EventHeaderView: UIView {
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var speakerName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var sessionDescription: UILabel!
    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var sessionThumbnail: UIImageView!
    
    func configure(event: Event, company: Company){
        companyName.text = company.name
        room.text = event.room
        speakerName.text = event.speaker
        sessionDescription.text = event.descriptionText
        sessionName.text = event.name
        layoutSubviews()

        let timeFormatter  = NSDateFormatter()
        timeFormatter.timeZone = NSTimeZone(name: "UTC")
        timeFormatter.dateFormat            = "hh:mm a";
        var startTimeString: String        = "00:00"
        var endTimeString: String          = "00:00"

        startTimeString = timeFormatter.stringFromDate(event.startTime)
        endTimeString = timeFormatter.stringFromDate(event.endTime)

        time.text = startTimeString + " - " + endTimeString
    }

    override func awakeFromNib() {
    }
}