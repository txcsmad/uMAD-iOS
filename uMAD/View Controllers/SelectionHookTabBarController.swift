import Foundation
import UIKit
import Parse

class SelectionHookTabBarController: UITabBarController {
    /** Changing the delegate of a UITabBarController is not allowed,
         so we'll override the delegate selection notification implementation.
        */
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        let cleanedItemName = item.title!.stringByReplacingOccurrencesOfString(" ", withString: "_")
        let eventName = "opened\(cleanedItemName)Tab"
        // UITabBarController doesn't implement this function, so no need to call super
        PFAnalytics.trackEventInBackground(eventName, dimensions:nil, block: nil)
    }
}
