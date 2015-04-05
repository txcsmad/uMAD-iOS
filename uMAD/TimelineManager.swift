import Foundation

class TimelineManager {
    static var instance = TimelineManager()
    var consumerKey: String?
    var consumerSecret: String?
    var tweets = [Tweet]()
    var users = [String:User]()
    var userProfileImageCache = [String: UIImage]()
    var twitterHandle: String?
    var tweetBatchCount: UInt = 50
    var apiInterface: STTwitterAPI?

    private init(){

    }
    
    func configure(consumerKey: String, consumerSecret: String, twitterHandle: String, successBlock: (String!) -> (), errorBlock: (NSError!) -> ()){
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.twitterHandle = twitterHandle
        apiInterface = STTwitterAPI(appOnlyWithConsumerKey: consumerKey, consumerSecret: consumerSecret)
        apiInterface!.verifyCredentialsWithSuccessBlock(successBlock, errorBlock: errorBlock)

    }

    func loadTweets(successBlock: ()->(), errorBlock: (NSError!) -> ()){

        let internalSuccessBlock: ([AnyObject]!) -> () = { (response: [AnyObject]!) in
            self.tweets.removeAll(keepCapacity: true)

            for dictionary in response as! [NSDictionary] {
                self.tweets.append(Tweet(json: dictionary))
            }

            successBlock()
        }

        apiInterface!.getUserTimelineWithScreenName(twitterHandle, count: tweetBatchCount, successBlock: internalSuccessBlock, errorBlock: errorBlock)
    }
}