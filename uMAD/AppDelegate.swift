
import UIKit

let PARSE_APPLICATION_ID: String = "uY4oviE7S1f5tJ4naI4J0BExh6qSTYUwdQCpukoX"
let PARSE_CLIENT_KEY: String = "Y6X3s9CzWvduMX3P9oTB0mZBEphF9ntdKlj1HEU9"

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.setApplicationId(PARSE_APPLICATION_ID, clientKey: PARSE_CLIENT_KEY)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        var eventsViewController = UINavigationController(rootViewController: EventsViewController())
        eventsViewController.navigationBar.barTintColor = UIColor(red: 0.83, green: 0.18, blue: 0.13, alpha: 1.0)
        eventsViewController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        var twitterViewController = UINavigationController(rootViewController: TwitterViewController())
        twitterViewController.navigationBar.barTintColor = UIColor(red: 0.83, green: 0.18, blue: 0.13, alpha: 1.0)
        twitterViewController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        var sponsorsViewController = UINavigationController(rootViewController: SponsorsViewController())
        sponsorsViewController.navigationBar.barTintColor = UIColor(red: 0.83, green: 0.18, blue: 0.13, alpha: 1.0)
        sponsorsViewController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        sponsorsViewController.tabBarItem.title = "Sponsors"
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [eventsViewController, twitterViewController, sponsorsViewController]
        tabBarController.tabBar.tintColor = UIColor(red: 0.83, green: 0.18, blue: 0.13, alpha: 1.0)
        
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
        window?.rootViewController = tabBarController
        
        window?.makeKeyAndVisible()
        
        return true
    }

}

