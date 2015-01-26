
import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.setApplicationId("uY4oviE7S1f5tJ4naI4J0BExh6qSTYUwdQCpukoX", clientKey: "Y6X3s9CzWvduMX3P9oTB0mZBEphF9ntdKlj1HEU9")
        
        var eventsViewController = UINavigationController(rootViewController: EventsViewController())
        var twitterViewController = UINavigationController(rootViewController: TwitterViewController())
        var sponsorsViewController = UINavigationController(rootViewController: SponsorsViewController())
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [eventsViewController, twitterViewController, sponsorsViewController]
        
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
        window?.rootViewController = tabBarController
        
        window?.makeKeyAndVisible()
        
        return true
    }

}

