
import UIKit

let PARSE_APPLICATION_ID: String = "uY4oviE7S1f5tJ4naI4J0BExh6qSTYUwdQCpukoX"
let PARSE_CLIENT_KEY: String = "Y6X3s9CzWvduMX3P9oTB0mZBEphF9ntdKlj1HEU9"

let TABBAR_HEIGHT: CGFloat = 49.00

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.setApplicationId(PARSE_APPLICATION_ID, clientKey: PARSE_CLIENT_KEY)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.83, green: 0.18, blue: 0.13, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        var eventsViewController = UINavigationController(rootViewController: EventsViewController())
        var twitterViewController = UINavigationController(rootViewController: TwitterViewController())
        var sponsorsViewController = UINavigationController(rootViewController: SponsorsViewController())
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [eventsViewController, twitterViewController, sponsorsViewController]
        tabBarController.tabBar.tintColor = UIColor(red: 0.83, green: 0.18, blue: 0.13, alpha: 1.0)
        
        var eventsTabImage: UIImage = UIImage(named: "events.png")!
        var resizedEventsTabImage: UIImage = eventsTabImage.imageScaledToSize(CGSizeMake(25.00, 25.00))
        eventsViewController.tabBarItem = UITabBarItem(title: "Events", image: resizedEventsTabImage, tag: 0)
        
        var twitterTabImage: UIImage = UIImage(named: "twitter.png")!
        var resizedTwitterTabImage: UIImage = twitterTabImage.imageScaledToSize(CGSizeMake(25.00, 25.00))
        twitterViewController.tabBarItem = UITabBarItem(title: "Twitter", image: resizedTwitterTabImage, tag: 0)
        
        var sponsorsTabImage: UIImage = UIImage(named: "sponsors.png")!
        var resizedSponsorsTabImage: UIImage = sponsorsTabImage.imageScaledToSize(CGSizeMake(25.00, 25.00))
        sponsorsViewController.tabBarItem = UITabBarItem(title: "Sponsors", image: resizedSponsorsTabImage, tag: 0)
        
        tabBarController.tabBar.translucent = false
        
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
        window?.rootViewController = tabBarController
        
        window?.makeKeyAndVisible()
        
        return true
    }

}

