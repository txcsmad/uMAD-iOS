import UIKit

let FONT_SIZE: CGFloat = 17.00
let DETAIL_FONT_SIZE: CGFloat = 12.00
let TINT_COLOR = UIColor(hue: 359.0, saturation: 0.91, brightness: 0.83, alpha: 1.0)
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.enableLocalDatastore()
        Parse.setApplicationId(PARSE_APPLICATION_ID, clientKey: PARSE_CLIENT_KEY)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        UINavigationBar.appearance().barTintColor = TINT_COLOR
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        var eventsViewController = UINavigationController(rootViewController: EventsViewController())
        var twitterViewController = UINavigationController(rootViewController: TwitterViewController())
        var sponsorsViewController = UINavigationController(rootViewController: SponsorsViewController())
        var aboutViewController = UINavigationController(rootViewController: AboutViewController())
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [eventsViewController, twitterViewController, sponsorsViewController, aboutViewController]
        tabBarController.view.tintColor = TINT_COLOR

        eventsViewController.tabBarItem.title = "Events"
        eventsViewController.tabBarItem.image = UIImage(named: "calendar.png")
        eventsViewController.tabBarItem.selectedImage = UIImage(named: "calendar-filled.png")

        twitterViewController.tabBarItem.title = "Twitter"
        twitterViewController.tabBarItem.image = UIImage(named: "twitter.png")
        twitterViewController.tabBarItem.selectedImage = UIImage(named: "twitter-filled.png")

        sponsorsViewController.tabBarItem.title = "Sponsors"
        sponsorsViewController.tabBarItem.image = UIImage(named: "sponsors.png")
        sponsorsViewController.tabBarItem.selectedImage = UIImage(named: "sponsors-filled.png")

        aboutViewController.tabBarItem.title = "About Us"
        aboutViewController.tabBarItem.image = UIImage(named: "aboutus.png")
        aboutViewController.tabBarItem.selectedImage = UIImage(named: "aboutus-filled.png")
        
        tabBarController.tabBar.translucent = false
        
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
        window?.rootViewController = tabBarController
        
        window?.makeKeyAndVisible()
        
        return true
    }

}

