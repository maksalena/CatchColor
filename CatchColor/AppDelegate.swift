//
//  AppDelegate.swift
//  CatchColor
//
//  Created by Алёна Максимова on 22.09.2024.
//

import UIKit
import AppsFlyerLib

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppsFlyerLib.shared().appsFlyerDevKey = "6AuVcK2LPvyWmyMvfc6P6T"
        AppsFlyerLib.shared().appleAppID = "6686408560"
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 6)
        
        window = UIWindow()
        let startScreenVC = UpdateLevelsOnOldVersion()
        
        let navigationController = UINavigationController(rootViewController: startScreenVC)
        
        // Customize the back button appearance for the entire UINavigationBar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backButtonAppearance.normal.titleTextAttributes = [
            .font: UIFont(name: "Courier", size: 18)!,
            .foregroundColor: UIColor.white
        ]
        
        // Apply the appearance to the navigation bar
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.tintColor = .white
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }

    static var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().start()
    }
}

