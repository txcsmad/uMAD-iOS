
import Foundation

struct Tweet {
    
    var createdAt: NSDate
    var id: String
    var text: String
    var user: User
    
    init(json: NSDictionary) {
        var tweet: NSDictionary!
        if let retweetedStatus = json["retweeted_status"] as? NSDictionary {
            tweet = retweetedStatus
        } else {
            tweet = json
        }
        
        id = tweet["id_str"] as! String
        
        let createdAtString = tweet["created_at"] as! String
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        createdAt = dateFormatter.dateFromString(createdAtString)!
        
        text = tweet["text"] as! String
        
        let userDictionary = tweet["user"] as! NSDictionary
        user = User(json: userDictionary)
    }
    
}

struct User {
    
    var id: String
    var name: String
    var screenName: String
    var profileImageUrl: NSURL
    
    init(json: NSDictionary) {
        id = json["id_str"] as! String
        
        name = json["name"] as! String
        
        screenName = json["screen_name"] as! String
        
        let profileImageUrlString = json["profile_image_url_https"] as! String
        let biggerProfileImageUrlString = profileImageUrlString.stringByReplacingOccurrencesOfString("normal", withString: "bigger", options: .LiteralSearch, range: nil)
        profileImageUrl = NSURL(string: biggerProfileImageUrlString)!
    }
    
}