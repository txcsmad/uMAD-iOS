import UIKit
import Parse
import Fabric
import TwitterKit
import SnapKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var currentUMAD: UMAD?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        Fabric.with([Twitter.self])
        registerParseSubclasses()
        Parse.setApplicationId(Config.parseAppID, clientKey: Config.parseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)

        PFConfig.getConfigInBackgroundWithBlock(nil)
        let umadQuery = UMAD.query()
        umadQuery?.orderByDescending("year")
        umadQuery?.limit = 1
        do {
             // A large amount of the code depends on knowing the latest conference.
             // Making this synchronous makes it easier to ensure that the app is showing
             // the latest information.
            let results = try umadQuery?.findObjects()
            if let resultUMADs = results as? [UMAD],
                let umad = resultUMADs.first {
                    AppDelegate.currentUMAD = umad
            }
        } catch {
            print("Configure a UMAD class to represent the current conference")
        }

        // Register for push notifications
        let userNotificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        UINavigationBar.appearance().barTintColor = Config.tintColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        let tabBarController = configureTabBarController()

        window = UIWindow()
        window?.rootViewController = tabBarController

        window?.makeKeyAndVisible()
        window?.tintColor = Config.tintColor

        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current Installation and save it to Parse
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func registerParseSubclasses() {
        Session.registerSubclass()
        Company.registerSubclass()
        User.registerSubclass()
        UMAD.registerSubclass()
        UMADApplication.registerSubclass()
        UMADApplicationStatus.registerSubclass()
    }

    func configureTabBarController() -> UITabBarController {
        let sessionsViewController = UINavigationController(rootViewController: SessionsViewController())
        let twitterViewController = UINavigationController(rootViewController: TimelineViewController())
        let sponsorsViewController = UINavigationController(rootViewController: SponsorsViewController())
        let aboutViewController = UINavigationController(rootViewController: AboutViewController())

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [sessionsViewController, twitterViewController, sponsorsViewController, aboutViewController]

        sessionsViewController.tabBarItem.title = "Sessions"
        sessionsViewController.tabBarItem.image = UIImage(named: "sessions")
        sessionsViewController.tabBarItem.selectedImage = UIImage(named: "sessions-selected")

        twitterViewController.tabBarItem.title = "Twitter"
        twitterViewController.tabBarItem.image = UIImage(named: "twitter")
        twitterViewController.tabBarItem.selectedImage = UIImage(named: "twitter-selected")

        sponsorsViewController.tabBarItem.title = "Sponsors"
        sponsorsViewController.tabBarItem.image = UIImage(named: "sponsors")
        sponsorsViewController.tabBarItem.selectedImage = UIImage(named: "sponsors-selected")

        aboutViewController.tabBarItem.title = "About"
        aboutViewController.tabBarItem.image = UIImage(named: "aboutus.png")
        aboutViewController.tabBarItem.selectedImage = UIImage(named: "aboutus-filled.png")
        return tabBarController
    }

}
