//
//  AppDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 04/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        debugPrint(#function)
        debugPrint(launchOptions ?? "")

        let acceptAction = UIMutableUserNotificationAction()
        // The identifier that you use internally to handle the action.
        acceptAction.identifier = "windmill.status.deployed"
        
        // The localized title of the action button.
        acceptAction.title = "Install"
        
        // Specifies whether the app must be in the foreground to perform the action.
        acceptAction.activationMode = .background;

        let inviteCategory = UIMutableUserNotificationCategory()
        
        // Identifier to include in your push payload and local notification
        inviteCategory.identifier = "windmill.status.deployed";
        
        // Set the actions to display in the default context
        inviteCategory.setActions([acceptAction], for: .minimal)
        
        let userNotificationSettings = UIUserNotificationSettings(types: .alert, categories: [inviteCategory])
        
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(userNotificationSettings)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        debugPrint("\(#function)")
        debugPrint(notificationSettings)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint(error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        debugPrint("\(#function)")
        
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)

    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        debugPrint("\(#function)")
        debugPrint(userInfo)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        
        
        debugPrint(#function)
        if let identifier = identifier{
            switch identifier {
            case "windmill.status.deployed":
                debugPrint("\(identifier):\(userInfo)")
            default:
                debugPrint("\(identifier):\(userInfo)")
            }
        }
        
        completionHandler()
    }
    
}

