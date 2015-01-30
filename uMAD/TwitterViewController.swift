
import UIKit
import Social

let TWITTER_CONSUMER_KEY = "SyuNTOUuYd5EbejRrzTXoNys3"
let TWITTER_CONSUMER_SECRET = "6TzSt7ruEZCUElzui3U98UxovXm88ZiByPL3ARMBjkUbkIgdv9"

let UTCS_MAD_SCREEN_NAME = "@utcsmad"
let TWEET_BATCH_COUNT: UInt = 100

class TwitterViewController: UITableViewController {
    
    let twitter = STTwitterAPI(appOnlyWithConsumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET)
    var tweets = [Tweet]()
    var userProfileImageCache = [String: UIImage]()

    func composeTweet() {
        let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        tweetSheet.setInitialText(UTCS_MAD_SCREEN_NAME + " ")
        presentViewController(tweetSheet, animated: true, completion: nil)
    }
    
    func presentAlertControllerForError(error: NSError) {
        let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func reloadTweets() {
        twitter.getUserTimelineWithScreenName(UTCS_MAD_SCREEN_NAME, count: TWEET_BATCH_COUNT, successBlock: { (response: [AnyObject]!) in
            self.tweets.removeAll(keepCapacity: true)
            
            for dictionary in response as [NSDictionary] {
                self.tweets.append(Tweet(json: dictionary))
            }

            dispatch_async(dispatch_get_main_queue(), { () in
                self.tableView.reloadData()
                
                self.refreshControl?.endRefreshing()
            })
        }, { (error: NSError!) in
            self.presentAlertControllerForError(error)
        })
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: Selector("reloadTweets"), forControlEvents: .ValueChanged)
        refreshControl = refresh
        
        navigationItem.title = "Twitter"
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: Selector("composeTweet"))
        }
        
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        tableView.registerNib(UINib(nibName: "TweetTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "tweet_cell")
        
        twitter.verifyCredentialsWithSuccessBlock({ (bearerToken: String!) in
            self.reloadTweets()
        }, errorBlock: { (error: NSError!) in
            self.presentAlertControllerForError(error)
        })
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tweet_cell", forIndexPath: indexPath) as TweetTableViewCell
        
        let tweet = tweets[indexPath.row]
        
        let attributedName = NSMutableAttributedString(string: "\(tweet.user.name) @\(tweet.user.screenName)")
        let screenNameRange = NSMakeRange(countElements(tweet.user.name) + 1, countElements(tweet.user.screenName) + 1)
        attributedName.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: screenNameRange)
        attributedName.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: screenNameRange)
        cell.userNameAndScreenNameLabel.attributedText = attributedName
  
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
        let openInAlertController = UIAlertController(title: "Open Tweet in...", message: nil, preferredStyle: .ActionSheet)
        
        let tweet = tweets[indexPath.row]
        
        var clients = [(String, String)]()
        clients.append(("Twitter", "twitter://status?id=\(tweet.id)"))
        clients.append(("Tweetbot", "tweetbot://\(tweet.user.id)/status/\(tweet.id)"))
        clients.append(("Twitterrific", "twitterrific:///tweet?id=\(tweet.id)"))

        for client in clients {
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: client.1)!) {
                openInAlertController.addAction(UIAlertAction(title: client.0, style: .Default, handler: { (action: UIAlertAction!) in
                    UIApplication.sharedApplication().openURL(NSURL(string: client.1)!)
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }))
            }
        }
        
        openInAlertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }))
        
        presentViewController(openInAlertController, animated: true, completion: nil)
    }
    
}
