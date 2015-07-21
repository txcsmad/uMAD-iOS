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
        tableView.registerNib(UINib(nibName: "TweetTableViewCellWithImage", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "tweet_cell_with_image")

    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TimelineManager.instance.tweets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tweet = TimelineManager.instance.tweets[indexPath.row]

        let identifier: String
        if tweet.images.count > 0 {
            identifier = "tweet_cell_with_image"

        } else {
            identifier = "tweet_cell"
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! TweetTableViewCell
        assert({ () -> Bool in
            if let container = cell.imagesContainer {
                return container.subviews.count == 0
            }
            return true
            }())

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
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { _ in
                if let imageData = NSData(contentsOfURL: imageURL) {
                    let image = UIImage(data: imageData)

                    dispatch_async(dispatch_get_main_queue()) { _ in
                        let imageView = UIImageView(image: image)
                        imageView.contentMode = .ScaleAspectFill
                        imageView.clipsToBounds = true
                        imageView.layer.cornerRadius = 4.0
                        cell.imagesContainer!.addArrangedSubview(imageView)
                        cell.layoutSubviews()
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

        let tweet = TimelineManager.instance.tweets[indexPath.row]
        let url: NSURL
        if twitterInstalled {
           url = NSURL(string: "\(targetURL)\(tweet.id)")!
        } else {
            url = NSURL(string: "\(targetURL)\(tweet.user.screenName)/status/\(tweet.id)")!
        }

        UIApplication.sharedApplication().openURL(url)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
