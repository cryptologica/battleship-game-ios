//
//  AppDelegate.swift
//  Project3
//
//  Created by JT Newsome on 3/17/16.
//  Copyright © 2016 JT Newsome. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let lobbyViewController: LobbyViewController = LobbyViewController()
        let navController: UINavigationController = UINavigationController()
        navController.pushViewController(lobbyViewController, animated: false)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = navController
        window!.makeKeyAndVisible()
        
        return true;
    }

}

