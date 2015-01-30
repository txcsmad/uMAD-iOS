
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
        twitterViewController.tabBarItem.title = "Twitter"
        
        var sponsorsViewController = UINavigationController(rootViewController: SponsorsViewController())
        sponsorsViewController.tabBarItem.title = "Sponsors"
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [eventsViewController, twitterViewController, sponsorsViewController]
        tabBarController.tabBar.tintColor = UIColor(red: 0.83, green: 0.18, blue: 0.13, alpha: 1.0)
        
        var tabImage: UIImage = UIImage(named: "events.png")!
        var resizedImage: UIImage = tabImage.imageScaledToSize(CGSizeMake(25.00, 25.00))
        eventsViewController.tabBarItem = UITabBarItem(title: "Events", image: resizedImage, tag: 0)
        
        tabBarController.tabBar.translucent = false
        
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
        window?.rootViewController = tabBarController
        
        window?.makeKeyAndVisible()
        
        return true
    }

}

