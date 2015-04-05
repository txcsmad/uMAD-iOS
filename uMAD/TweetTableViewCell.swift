import UIKit

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet var userProfileImageView: UIImageView!
    @IBOutlet var header: UILabel!
    @IBOutlet var tweetText: UILabel!
    @IBOutlet var tweetImage: UIImageView!
    @IBOutlet var imageHeight: NSLayoutConstraint!

    static let dateComponentsFormatter: NSDateComponentsFormatter = {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Abbreviated
        return formatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        userProfileImageView.layer.cornerRadius = 4
        tweetImage.layer.cornerRadius = 4
    }

    func configure(tweet: Tweet){
        let timeSince = timeSinceString(tweet.createdAt)
        let attributedHeader = NSMutableAttributedString(string: "\(tweet.user.name) @\(tweet.user.screenName) \(timeSince)")
        let screenNameRange = NSMakeRange(count(tweet.user.name) + 1, count(timeSince) + 1)
        let timeSinceRange = NSMakeRange(screenNameRange.length + screenNameRange.location, count(tweet.user.screenName) + 1)
        let screenNameAndTimeSinceRange = NSMakeRange(screenNameRange.location, screenNameRange.length + timeSinceRange.length)
        attributedHeader.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(12), range: screenNameAndTimeSinceRange)
        attributedHeader.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: screenNameAndTimeSinceRange)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Left
        let tab = NSTextTab(textAlignment: .Right, location: CGFloat(screenNameRange.location), options: nil)
        paragraphStyle.tabStops = [tab]

        attributedHeader.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: timeSinceRange)
        header.attributedText = attributedHeader

        tweetText.text = tweet.text

    }

    private func timeSinceString(date: NSDate) -> String{
        let recentUnitFlags: NSCalendarUnit = .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond
        var dateComponents = NSCalendar.autoupdatingCurrentCalendar().components(.CalendarUnitDay, fromDate: date, toDate: NSDate(), options: nil)
        if dateComponents.day == 0 {
            dateComponents = NSCalendar.autoupdatingCurrentCalendar().components(recentUnitFlags, fromDate: date, toDate: NSDate(), options: nil)

        }

        return "\(TweetTableViewCell.dateComponentsFormatter.stringFromDateComponents(dateComponents)!)"
        
    }

    override func prepareForReuse() {
        tweetImage.image = nil
        tweetImage.hidden = true
        userProfileImageView.image = nil
        imageHeight.constant = 0
    }
    
}