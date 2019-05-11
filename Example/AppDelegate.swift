//
//  AppDelegate.swift
//  ShuffleExample
//
//  Created by Mac Gallagher on 6/1/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let navController = UINavigationController(rootViewController: TinderViewController())
        navController.navigationBar.isTranslucent = false
        window?.rootViewController = navController
        return true
    }
}
