import UIKit
import Parse
import Fabric
import TwitterKit
import SnapKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var currentUMAD: UMAD?
    private var tabBarController: UITabBarController!
    private var splashScreen: SplashViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        Fabric.with([Twitter.self])
        registerParseSubclasses()
        Parse.setApplicationId(Config.parseAppID, clientKey: Config.parseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)

        PFConfig.getConfigInBackgroundWithBlock(nil)

        // Register for push notifications
        let userNotificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default

        UINavigationBar.appearance().tintColor = Color.AppTint.getUIColor()

        splashScreen = SplashViewController(nibName: "Splash", bundle: nil)

        window = UIWindow()
        window?.rootViewController = splashScreen

        window?.makeKeyAndVisible()
        window?.tintColor = Config.tintColor

        tabBarController = configureTabBarController()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentTabs", name: "shouldPresentTabs", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentSplash", name: "shouldPresentSplash", object: nil)
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
        UMADSponsor.registerSubclass()
        UMADApplication.registerSubclass()
        UMADApplicationStatus.registerSubclass()
    }

    func configureTabBarController() -> UITabBarController {
        let sessionsViewController = UINavigationController(rootViewController: SessionsViewController())
        let twitterViewController = UINavigationController(rootViewController: TimelineViewController())
        let sponsorsViewController = UINavigationController(rootViewController: SponsorsViewController())

        let tabBarController = SelectionHookTabBarController()
        tabBarController.viewControllers = [sessionsViewController, twitterViewController, sponsorsViewController]

        sessionsViewController.tabBarItem.title = "Sessions"
        sessionsViewController.tabBarItem.image = UIImage(named: "sessions")
        sessionsViewController.tabBarItem.selectedImage = UIImage(named: "sessions-selected")

        twitterViewController.tabBarItem.title = "Twitter"
        twitterViewController.tabBarItem.image = UIImage(named: "twitter")
        twitterViewController.tabBarItem.selectedImage = UIImage(named: "twitter-selected")

        sponsorsViewController.tabBarItem.title = "Sponsors"
        sponsorsViewController.tabBarItem.image = UIImage(named: "sponsors")
        sponsorsViewController.tabBarItem.selectedImage = UIImage(named: "sponsors-selected")

        return tabBarController
    }

    func presentTabs() {
        window?.rootViewController = tabBarController
        splashScreen = nil

    }

    func presentSplash() {
        if splashScreen == nil {
            splashScreen = SplashViewController(nibName: "Splash", bundle: nil)
        }
        window?.rootViewController = splashScreen
    }

}
