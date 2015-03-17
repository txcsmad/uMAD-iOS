import UIKit

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet var userProfileImageView: UIImageView!
    @IBOutlet var userNameAndScreenNameLabel: UILabel!
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var tweetTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userProfileImageView.backgroundColor = UIColor.lightGrayColor()
        userProfileImageView.layer.cornerRadius = 8
        userProfileImageView.clipsToBounds = true
    }
    
}