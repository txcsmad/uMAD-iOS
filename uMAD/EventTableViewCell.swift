import Foundation

class EventTableViewCell: PFTableViewCell {
    static let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(name: "UTC")
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(event: Event) {
        let startTimeString = EventTableViewCell.formatter.stringFromDate(event.startTime)
        let endTimeString = EventTableViewCell.formatter.stringFromDate(event.endTime)
        detailTextLabel?.textColor = UIColor.lightGrayColor()

        textLabel?.text = event.name
        detailTextLabel?.text = "\(startTimeString) - \(endTimeString) – \(event.room)"

        imageView?.contentMode = .ScaleAspectFit
        imageView?.image = UIImage(named: "placeholder")
        event.company.fetchIfNeededInBackgroundWithBlock { (company, error) -> Void in
            let company = company as! Company
            self.imageView?.file = company.thumbnail
            self.imageView?.loadInBackground({ (image, error) -> Void in
                self.setNeedsDisplay()
            })
        }


    }
}