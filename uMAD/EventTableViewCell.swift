import Foundation

class EventTableViewCell: PFTableViewCell {
    static let formatter = NSDateFormatter()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        EventTableViewCell.formatter.timeZone = NSTimeZone(name: "UTC")
        EventTableViewCell.formatter.dateFormat = "hh:mm a"
    }

    func configure(event: Event) {
        let startTimeString = EventTableViewCell.formatter.stringFromDate(event.startTime)
        let endTimeString = EventTableViewCell.formatter.stringFromDate(event.endTime)

        detailTextLabel?.textColor = UIColor.lightGrayColor()

        textLabel?.text = event.name
        detailTextLabel?.text = "\(startTimeString) - \(endTimeString) – \(event.room)"

        imageView?.contentMode = .ScaleAspectFit
        imageView?.image = UIImage(named: "placeholder.png")
        event.company.fetchIfNeededInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
            self.imageView?.file = event.company.thumbnail
            self.imageView?.loadInBackground({ (image: UIImage?, error: NSError?) -> Void in
                self.setNeedsDisplay()
            })
        }


    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}