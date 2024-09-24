import UIKit
import AppsFlyerLib

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        AppsFlyerLib.shared().appsFlyerDevKey = "6AuVcK2LPvyWmyMvfc6P6T"
        AppsFlyerLib.shared().appleAppID = "6714485366"
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 7)
        return true
    }
    
    static var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().start()
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
