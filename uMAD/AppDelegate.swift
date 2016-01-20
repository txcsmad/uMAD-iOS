import UIKit
import Parse
import Fabric
import TwitterKit


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var currentUMAD: UMAD?
    private var tabBarController: UITabBarController!
    private var splashScreen: SplashViewController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        Fabric.with([Twitter.self])
        registerParseSubclasses()
        Parse.setApplicationId(Config.parseAppID, clientKey: Config.parseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)

        PFConfig.getConfigInBackgroundWithBlock(nil)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        UINavigationBar.appearance().barTintColor = Config.tintColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        splashScreen = SplashViewController(nibName: "Splash", bundle: nil)

        window = UIWindow()
        window?.rootViewController = splashScreen

        window?.makeKeyAndVisible()
        window?.tintColor = Config.tintColor

        tabBarController = configureTabBarController()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentTabs", name: "shouldPresentTabs", object: nil)
        return true
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
        sessionsViewController.tabBarItem.image = UIImage(named: "calendar.png")
        sessionsViewController.tabBarItem.selectedImage = UIImage(named: "calendar-filled.png")

        twitterViewController.tabBarItem.title = "Twitter"
        twitterViewController.tabBarItem.image = UIImage(named: "twitter.png")
        twitterViewController.tabBarItem.selectedImage = UIImage(named: "twitter-filled.png")

        sponsorsViewController.tabBarItem.title = "Sponsors"
        sponsorsViewController.tabBarItem.image = UIImage(named: "sponsors.png")
        sponsorsViewController.tabBarItem.selectedImage = UIImage(named: "sponsors-filled.png")

        aboutViewController.tabBarItem.title = "About"
        aboutViewController.tabBarItem.image = UIImage(named: "aboutus.png")
        aboutViewController.tabBarItem.selectedImage = UIImage(named: "aboutus-filled.png")
        return tabBarController
    }

    func presentTabs() {
        window?.rootViewController = tabBarController
    }

}
