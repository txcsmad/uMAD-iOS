import UIKit
import ParseCrashReporting

let FONT_SIZE: CGFloat = 17.00
let DETAIL_FONT_SIZE: CGFloat = 12.00
let tintColor = UIColor(hue: 359.0, saturation: 0.91, brightness: 0.83, alpha: 1.0)
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        ParseCrashReporting.enable()
        Event.registerSubclass()
        Company.registerSubclass()
        Parse.setApplicationId(Config.parseAppID, clientKey: Config.parseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)

        PFConfig.getConfigInBackgroundWithBlock(nil)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        UINavigationBar.appearance().barTintColor = tintColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        
        let eventsViewController = UINavigationController(rootViewController: EventsViewController())
        let twitterViewController = UINavigationController(rootViewController: TwitterViewController())
        let sponsorsViewController = UINavigationController(rootViewController: SponsorsViewController())
        let aboutViewController = UINavigationController(rootViewController: AboutViewController())
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [eventsViewController, twitterViewController, sponsorsViewController, aboutViewController]
        
        eventsViewController.tabBarItem.title = "Events"
        eventsViewController.tabBarItem.image = UIImage(named: "calendar.png")
        eventsViewController.tabBarItem.selectedImage = UIImage(named: "calendar-filled.png")

        twitterViewController.tabBarItem.title = "Twitter"
        twitterViewController.tabBarItem.image = UIImage(named: "twitter.png")
        twitterViewController.tabBarItem.selectedImage = UIImage(named: "twitter-filled.png")

        sponsorsViewController.tabBarItem.title = "Sponsors"
        sponsorsViewController.tabBarItem.image = UIImage(named: "sponsors.png")
        sponsorsViewController.tabBarItem.selectedImage = UIImage(named: "sponsors-filled.png")

        aboutViewController.tabBarItem.title = "About"
        aboutViewController.tabBarItem.image = UIImage(named: "aboutus.png")
        aboutViewController.tabBarItem.selectedImage = UIImage(named: "aboutus-filled.png")
        
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
        window?.rootViewController = tabBarController
        
        window?.makeKeyAndVisible()
        window?.tintColor = tintColor
        
        return true
    }

}

