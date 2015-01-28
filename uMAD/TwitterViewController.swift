
import UIKit

let TWITTER_CONSUMER_KEY = "SyuNTOUuYd5EbejRrzTXoNys3"
let TWITTER_CONSUMER_SECRET = "6TzSt7ruEZCUElzui3U98UxovXm88ZiByPL3ARMBjkUbkIgdv9"

let UTCS_MAD = "utcsmad"
let TWEET_BATCH_COUNT: UInt = 100

class TwitterViewController: UITableViewController {
    
    let twitter = STTwitterAPI(appOnlyWithConsumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET)
    var tweets = [NSDictionary]()
    
    func composeTweet() {
        println("Compose tweet")
    }
    
    func reloadTweets() {
        twitter.getUserTimelineWithScreenName(UTCS_MAD, count: TWEET_BATCH_COUNT, successBlock: { (response: [AnyObject]!) in
            self.tweets = response as [NSDictionary]
            self.tableView.reloadData()
        }, { (error: NSError!) in
            UIAlertController.presentErrorAlertControllerInViewController(self, error: error)
        })
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.tabBarItem.title = "Twitter"
        
        navigationItem.title = "Twitter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: Selector("composeTweet"))
        
        tableView.registerNib(UINib(nibName: "TweetTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TweetCell")
        // tableView.registerClass(TweetTableViewCell.classForCoder(), forCellReuseIdentifier: "TweetCell")
        
        twitter.verifyCredentialsWithSuccessBlock({ (bearerToken: String!) in
            self.reloadTweets()
        }, errorBlock: { (error: NSError!) in
            println("couldn't verify credentials")
            UIAlertController.presentErrorAlertControllerInViewController(self, error: error)
        })
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as UITableViewCell
        
        let tweet = tweets[indexPath.row]
        let user = tweet["user"] as NSDictionary
    
        let name = user["name"] as String
        let screenName = user["screen_name"] as String
        
        let text = tweet["text"] as String
        
        cell.textLabel?.text = "\(name) (@\(screenName))"
        cell.detailTextLabel?.text = "\(text)"
        
        return cell
    }
    
}

class TweetTableViewCell: UITableViewCell {
    
}

extension UIAlertController {
    
    class func presentErrorAlertControllerInViewController(viewController: UIViewController, error: NSError) {
        let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
