
import UIKit

let TWITTER_CONSUMER_KEY = "SyuNTOUuYd5EbejRrzTXoNys3"
let TWITTER_CONSUMER_SECRET = "6TzSt7ruEZCUElzui3U98UxovXm88ZiByPL3ARMBjkUbkIgdv9"

let UTCS_MAD = "utcsmad"
let TWEET_BATCH_COUNT: UInt = 100

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
        
        id = tweet["id_str"] as String
        
        let createdAtString = tweet["created_at"] as String
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        createdAt = dateFormatter.dateFromString(createdAtString)!
        
        text = tweet["text"] as String
        
        let userDictionary = tweet["user"] as NSDictionary
        user = User(json: userDictionary)
    }
    
}

struct User {
    
    var name: String
    var screenName: String
    var profileImageUrl: NSURL
    
    init(json: NSDictionary) {
        name = json["name"] as String
        
        screenName = json["screen_name"] as String
        
        let profileImageUrlString = json["profile_image_url_https"] as String
        let biggerProfileImageUrlString = profileImageUrlString.stringByReplacingOccurrencesOfString("normal", withString: "bigger", options: .LiteralSearch, range: nil)
        profileImageUrl = NSURL(string: biggerProfileImageUrlString)!
    }
    
}

class TwitterViewController: UITableViewController {
    
    let twitter = STTwitterAPI(appOnlyWithConsumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET)
    var tweets = [Tweet]()
    var userProfileImageCache = [String: UIImage]()
    
    func attemptToOpenUrl(url: NSURL) {
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            let alertController = UIAlertController(title: "Oops!", message: "It doesn't look like you have that Twitter client installed.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func composeTweet() {
        println("Compose tweet")
    }
    
    func reloadTweets() {
        twitter.getUserTimelineWithScreenName(UTCS_MAD, count: TWEET_BATCH_COUNT, successBlock: { (response: [AnyObject]!) in
            self.tweets.removeAll(keepCapacity: true)
            
            for dictionary in response as [NSDictionary] {
                self.tweets.append(Tweet(json: dictionary))
            }

            dispatch_async(dispatch_get_main_queue(), { () in
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            })
        }, { (error: NSError!) in
            UIAlertController.presentErrorAlertControllerInViewController(self, error: error)
        })
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: Selector("reloadTweets"), forControlEvents: .ValueChanged)
        refreshControl = refresh
        
        navigationItem.title = "Twitter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: Selector("composeTweet"))
        
        tableView.registerNib(UINib(nibName: "TweetTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TweetCell")
        
        twitter.verifyCredentialsWithSuccessBlock({ (bearerToken: String!) in
            self.reloadTweets()
        }, errorBlock: { (error: NSError!) in
            UIAlertController.presentErrorAlertControllerInViewController(self, error: error)
        })
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as TweetTableViewCell
        
        let tweet = tweets[indexPath.row]
        
        cell.userNameAndScreenNameLabel.text = "\(tweet.user.name) - @\(tweet.user.screenName)"
  
        cell.tweetTextLabel.text = tweet.text
        
        let dateComponentsFormatter = NSDateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = .Abbreviated
        let unitFlags: NSCalendarUnit = .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond
        let dateComponents = NSCalendar.autoupdatingCurrentCalendar().components(unitFlags, fromDate: tweet.createdAt, toDate: NSDate(), options: nil)
        cell.createdAtLabel.text = "\(dateComponentsFormatter.stringFromDateComponents(dateComponents)!) ago"
        
        if let profileImage = userProfileImageCache[tweet.user.screenName] {
            cell.userProfileImageView.image = profileImage
        } else {
            cell.userProfileImageView.image = nil
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () in
                if let profileImageData = NSData(contentsOfURL: tweet.user.profileImageUrl) {
                    let profileImage = UIImage(data: profileImageData)
                    
                    dispatch_async(dispatch_get_main_queue(), { () in
                        self.userProfileImageCache[tweet.user.screenName] = profileImage
                        cell.userProfileImageView.image = profileImage
                        cell.setNeedsDisplay()
                    })
                }
            })
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tweet = tweets[indexPath.row]
        let openInAlertController = UIAlertController(title: "Open Tweet in...", message: "Select the Twitter client you would like to open this Tweet in. If you're unsure what this means, simply selecting Twitter is a safe bet.", preferredStyle: .ActionSheet)
        openInAlertController.addAction(UIAlertAction(title: "Twitter", style: .Default, handler: { (action: UIAlertAction!) in
            // Twitter
            self.attemptToOpenUrl(NSURL(string: "twitter://status?id=\(tweet.id)")!)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }))
        openInAlertController.addAction(UIAlertAction(title: "Tweetbot", style: .Default, handler: { (action: UIAlertAction!) in
            // Tweetbot tweetbot://<screenname>/status/<tweet_id>
            self.attemptToOpenUrl(NSURL(string: "tweetbot://<screenname>/status/<tweet_id>")!)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }))
        openInAlertController.addAction(UIAlertAction(title: "Twitterrific", style: .Default, handler: { (action: UIAlertAction!) in
            // Twitterific
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }))
        openInAlertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }))
        presentViewController(openInAlertController, animated: true, completion: nil)
    }
    
}

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

extension UIAlertController {
    
    class func presentErrorAlertControllerInViewController(viewController: UIViewController, error: NSError) {
        let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
