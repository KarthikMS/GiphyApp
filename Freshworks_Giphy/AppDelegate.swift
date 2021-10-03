//
//  AppDelegate.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 02/10/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Clearing disk cache on appLaunch.
        FWImageDiskCache().clear()
        
        return true
    }
}

// MARK: UISceneSession Lifecycle
extension AppDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
