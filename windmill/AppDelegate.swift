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
    


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        debugPrint(#function)
        debugPrint(launchOptions)

        let acceptAction = UIMutableUserNotificationAction()
        // The identifier that you use internally to handle the action.
        acceptAction.identifier = "windmill.status.deployed"
        
        // The localized title of the action button.
        acceptAction.title = "Install"
        
        // Specifies whether the app must be in the foreground to perform the action.
        acceptAction.activationMode = .Background;

        let inviteCategory = UIMutableUserNotificationCategory()
        
        // Identifier to include in your push payload and local notification
        inviteCategory.identifier = "windmill.status.deployed";
        
        // Set the actions to display in the default context
        inviteCategory.setActions([acceptAction], forContext: .Minimal)
        
        let userNotificationSettings = UIUserNotificationSettings(forTypes: .Alert, categories: [inviteCategory])
        
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(userNotificationSettings)
        

        dispatch_async(dispatch_get_main_queue()){
            //UIApplication.sharedApplication().openURL(NSURL(string: "itms-services://?action=download-manifest&url=https://windmillio.s3-eu-west-1.amazonaws.com/14810686-4690-4900-ADA5-8B0B7338AA39/io.windmill.windmill/windmill.plist")!)
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        debugPrint("\(#function)")
        debugPrint(notificationSettings)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        debugPrint(error)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        debugPrint("\(#function)")
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)

    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        debugPrint("\(#function)")
        debugPrint(userInfo)
        
//        works
//        let iTunesLink = "https://itunes.apple.com/us/app/apple-store/id375380948?mt=8"
//        UIApplication.sharedApplication().openURL(NSURL(string:iTunesLink)!)

    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        
        debugPrint(#function)
        if let identifier = identifier{
            switch identifier {
            case "windmill.status.deployed":
                //does not work
//                let iTunesLink = "https://itunes.apple.com/us/app/apple-store/id375380948?mt=8"
//                UIApplication.sharedApplication().openURL(NSURL(string:iTunesLink)!)

//                let viewController = self.window!.rootViewController as! ViewController
//                viewController.itmsURL = URL
                
                debugPrint("\(identifier):\(userInfo)")
            default:
                debugPrint("\(identifier):\(userInfo)")
            }
        }
        
        completionHandler()
    }
    
}

