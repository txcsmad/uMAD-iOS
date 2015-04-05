import Foundation

struct Tweet {

    static let dateFormatter: NSDateFormatter = {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        return dateFormatter
    }()
    let createdAt: NSDate
    let id: String
    let text: String
    let user: User
    var image: UIImage?
    
    init(json: NSDictionary) {
        let tweet: NSDictionary!
        if let retweetedStatus = json["retweeted_status"] as? NSDictionary {
            tweet = retweetedStatus
        } else {
            tweet = json
        }
        id = tweet["id_str"] as! String

        let createdAtString = tweet["created_at"] as! String
        createdAt = Tweet.dateFormatter.dateFromString(createdAtString)!
        
        text = tweet["text"] as! String
        
        let userDictionary = tweet["user"] as! NSDictionary
        user = User.getUser(userDictionary)
    }
    
}

