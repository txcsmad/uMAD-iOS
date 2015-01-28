
import UIKit

let TWITTER_CONSUMER_KEY = "SyuNTOUuYd5EbejRrzTXoNys3"
let TWITTER_CONSUMER_SECRET = "6TzSt7ruEZCUElzui3U98UxovXm88ZiByPL3ARMBjkUbkIgdv9"

struct Tweet {
    
    var createdAt: NSDate
    var favoriteCount: Int
    var text: String
    var retweetCount: Int
    var user: User
    
}

struct User {
    
    var name: String
    var screenName: String
    var profileImageURL: NSURL
    
}

class TwitterViewController: UITableViewController {
    
    let twitter = STTwitterAPI(appOnlyWithConsumerKey: TWITTER_CONSUMER_KEY, consumerSecret: TWITTER_CONSUMER_SECRET)
    var tweets = [NSDictionary]()
    
    func reloadTweets() {
        twitter.getSearchTweetsWithQuery("#dope", geocode: nil, lang: nil, locale: nil, resultType: nil, count: "200", until: nil, sinceID: nil, maxID: nil, includeEntities: nil, callback: nil, successBlock: { (_, response: [AnyObject]!) in
            self.tweets = response as [NSDictionary]
            
            self.tableView.reloadData()
        }, errorBlock: { (error: NSError!) in
            UIAlertController.presentErrorAlertControllerInViewController(self, error: error)
        })
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(TweetTableViewCell.classForCoder(), forCellReuseIdentifier: "TweetCell")
        
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIAlertController {
    
    class func presentErrorAlertControllerInViewController(viewController: UIViewController, error: NSError) {
        let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
