import Foundation
import TwitterKit

class TimelineViewController: TWTRTimelineViewController {
    convenience init() {
        let client = TWTRAPIClient()
        let dataSource = TWTRUserTimelineDataSource(screenName: Config.twitterHandle, APIClient: client)
        self.init(dataSource: dataSource)
        // To match the events view controller
        view.backgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)

        // Show Tweet actions
        showTweetActions = true

        // Set the navigation bar title
        title = "Twitter"
    }
}