import Foundation

class EventTableViewCell: UITableViewCell {
    static let formatter = NSDateFormatter()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        EventTableViewCell.formatter.timeZone = NSTimeZone(name: "UTC")
        EventTableViewCell.formatter.dateFormat = "hh:mm a"
    }

    func configure(event: Event, company: Company?) {
        let startTimeString = EventTableViewCell.formatter.stringFromDate(event.startTime)
        let endTimeString = EventTableViewCell.formatter.stringFromDate(event.endTime)

        detailTextLabel?.textColor = UIColor.lightGrayColor()

        textLabel?.text = event.name
        detailTextLabel?.text = "\(startTimeString) - \(endTimeString) – \(event.room)"

        imageView?.image =  UIImage(named: "mad_thumbnail.png")
        imageView?.image = company?.thumbnail

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}