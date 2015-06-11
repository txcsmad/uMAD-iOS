import UIKit
import Social

class TwitterViewController: UITableViewController {

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        PFAnalytics.trackEventInBackground("openedTwitterTab", dimensions:nil, block: nil)
        super.viewDidLoad()
        TimelineManager.instance.configure(Config.twitterConsumerKey, consumerSecret: Config.twitterConsumerSecret, twitterHandle: Config.twitterHandle, successBlock: { _ in
            self.reloadTweets()
        }) { (error) -> () in
            self.presentAlertControllerForError(error)
        }
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: Selector("reloadTweets"), forControlEvents: .ValueChanged)
        refreshControl = refresh
        
        navigationItem.title = "Twitter"

        dispatch_async(dispatch_get_main_queue()) { _ in
            
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: Selector("composeTweet"))
            }
        }
        
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        tableView.registerNib(UINib(nibName: "TweetTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "tweet_cell")

    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TimelineManager.instance.tweets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tweet_cell", forIndexPath: indexPath) as! TweetTableViewCell
        
        let tweet = TimelineManager.instance.tweets[indexPath.row]
        
        cell.configure(tweet)
        
        if let profileImage = TimelineManager.instance.userProfileImageCache[tweet.user.screenName] {
            cell.userProfileImageView.image = profileImage
        } else {
            cell.userProfileImageView.image = nil
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { _ in
                if let profileImageData = NSData(contentsOfURL: tweet.user.profileImageUrl) {
                    let profileImage = UIImage(data: profileImageData)
                    
                    dispatch_async(dispatch_get_main_queue()) { _ in
                        TimelineManager.instance.userProfileImageCache[tweet.user.screenName] = profileImage
                        cell.userProfileImageView.image = profileImage
                        cell.setNeedsDisplay()
                    }
                }
            }
        }

        for _ in tweet.urls {
        }

        for (imageURL, range) in tweet.images {
            cell.tweetImage.hidden = false
            cell.imageHeight.constant = 120
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { _ in
                if let imageData = NSData(contentsOfURL: imageURL) {
                    let image = UIImage(data: imageData)

                    dispatch_async(dispatch_get_main_queue()) { _ in
                        cell.tweetImage.image = image
                        cell.setNeedsDisplay()
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let twitterInstalled: Bool
        let targetURL:String
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "twitter://")!) {
            twitterInstalled = true
            targetURL = "twitter://status?id="
        }
        else {
            twitterInstalled = false
            targetURL = "https://twitter.com/"
        }
        let targetAppName = twitterInstalled ? "Twitter" : "Safari"
        let alertController = UIAlertController(title: "Open in \(targetAppName)", message: nil, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Open", style: .Default, handler: { (action: UIAlertAction!) in
            let tweet = TimelineManager.instance.tweets[indexPath.row]
            let url: NSURL
            if twitterInstalled {
               url = NSURL(string: "\(targetURL)\(tweet.id)")!
            } else {
                url = NSURL(string: "\(targetURL)\(tweet.user.screenName)/status/\(tweet.id)")!
            }

            UIApplication.sharedApplication().openURL(url)
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func composeTweet() {
        let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        tweetSheet.setInitialText(Config.twitterHandle + " ")
        PFAnalytics.trackEventInBackground("openedTweetComposeSheet", dimensions:nil, block: nil)
        presentViewController(tweetSheet, animated: true, completion: nil)
    }

    func presentAlertControllerForError(error: NSError) {
        let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }

    func reloadTweets() {
        TimelineManager.instance.loadTweets({ _ in
            dispatch_async(dispatch_get_main_queue()) { _ in
                UIView.transitionWithView(self.tableView, duration: 0.1, options: .ShowHideTransitionViews, animations: {
                    () -> Void in

                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.20 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.refreshControl!.endRefreshing()
                    }

                    self.tableView.reloadData()
                    }, completion: nil)
            }
            }, errorBlock: { (error) -> () in
                self.presentAlertControllerForError(error)
        })
    }

}
