import UIKit
import Social

class TwitterViewController: UITableViewController {
    
    var userProfileImageCache = [String: UIImage]()

    init() {
        super.init(style: .Plain)

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        PFAnalytics.trackEventInBackground("openedTwitterTab", dimensions:nil, block: nil)
        super.viewDidLoad()
        TimelineManager.instance.configure(Config.twitterConsumerKey, consumerSecret: Config.twitterConsumerSecret, twitterHandle: Config.twitterHandle, successBlock: { _ in
            TimelineManager.instance.loadTweets({ _ in
                self.tableView.reloadData()
            }, errorBlock: { (error) -> () in
                self.presentAlertControllerForError(error)
            })
        }) { (error) -> () in
            self.presentAlertControllerForError(error)
        }
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

    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TimelineManager.instance.tweets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tweet_cell", forIndexPath: indexPath) as! TweetTableViewCell
        
        let tweet = TimelineManager.instance.tweets[indexPath.row]
        
        cell.configure(tweet)
        
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

        for url in tweet.urls {
        }

        for (imageURL, range) in tweet.images {
            cell.tweetImage.hidden = false
            cell.imageHeight.constant = 100
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () in
                if let imageData = NSData(contentsOfURL: imageURL) {
                    let image = UIImage(data: imageData)

                    dispatch_async(dispatch_get_main_queue(), { () in
                        cell.tweetImage.image = image
                        cell.setNeedsDisplay()
                    })
                }
            })
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alertController = UIAlertController(title: "Open in Twitter", message: nil, preferredStyle: .Alert)        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Open", style: .Default, handler: { (action: UIAlertAction!) in
            let tweet = TimelineManager.instance.tweets[indexPath.row]
            let url = NSURL(string: "twitter://status?id=\(tweet.id)")!
            UIApplication.sharedApplication().openURL(url)
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return UIApplication.sharedApplication().canOpenURL(NSURL(string: "twitter://")!)
    }

    func composeTweet() {
        let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        tweetSheet.setInitialText(Config.twitterHandle + " ")
        presentViewController(tweetSheet, animated: true, completion: nil)
    }

    func presentAlertControllerForError(error: NSError) {
        let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }

    func reloadTweets() {

    }

}
