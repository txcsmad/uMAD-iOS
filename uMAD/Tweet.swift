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
    let urls: [(NSURL, NSRange)]
    let images: [(NSURL, NSRange)]
    
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

        var tempUrls = [(NSURL, NSRange)]()
        let entities = tweet["entities"] as! NSDictionary
        let urlDicts = entities["urls"] as? [NSDictionary]
        if urlDicts != nil {
            for urlDict in urlDicts!   {
                let indices = urlDict["indices"] as! [Int]
                let range = NSMakeRange(indices[0], indices[1])
                let url = NSURL(string: urlDict["expanded_url"] as! String)!
                tempUrls.append((url, range))
            }
        }
        urls = tempUrls

        var tempImages = [(NSURL, NSRange)]()
        let mediaDicts = entities["media"] as? [NSDictionary]
        if mediaDicts != nil {
            for mediaDict in mediaDicts!   {
                let indices = mediaDict["indices"] as! [Int]
                let range = NSMakeRange(indices[0], indices[1] - indices[0])
                let url = NSURL(string: mediaDict["media_url_https"] as! String)!
                tempImages.append((url, range))
            }
        }
        images = tempImages
    }
    
}

