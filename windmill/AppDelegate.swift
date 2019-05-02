//
//  AppDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 04/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit
import UserNotifications
import os
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {

    var window: UIWindow?
    
    var rootViewController: MainTabBarController? {
        return self.window?.rootViewController as? MainTabBarController
    }
    
    let accountResource = AccountResource(configuration: URLSessionConfiguration.background(withIdentifier: "io.windmill.windmill.manager"))
    let applicationStorage = ApplicationStorage.default
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.window?.makeKeyAndVisible()
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionExpired(notification:)), name: SubscriptionManager.SubscriptionExpired, object: nil)

        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        SubscriptionManager.shared.startProcessingPayments()
        
        return true
    }
    
    @objc func subscriptionExpired(notification: NSNotification) {
        
        guard let error = notification.userInfo?["error"] as? Error else {
            return
        }
        
        switch error {
        case let error as SubscriptionError:
            let alertController = UIAlertController.Windmill.makeSubscription(error: error)
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        default:
            let alertController = UIAlertController.Windmill.make(title: "Error", error: error)
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTouchUpInsideStore() {
        guard let initialViewController = WindmillApp.Storyboard.purchase().instantiateInitialViewController() as? UINavigationController else {
            return
        }
        
        self.window?.rootViewController?.present(initialViewController, animated: true)
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
        
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
        
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: UIApplication.shared.registerForRemoteNotifications()
    
    /**
     Registers the device token used by APNs with the windmill service under the current account.
     
     "After successful APNs registration, the app object contacts APNs only when the device token has changed; otherwise, calling the registerForRemoteNotifications method results in a call to the application:didRegisterForRemoteNotificationsWithDeviceToken: method which returns the existing token quickly."
     
     If the device token changes while your app is running, the app object calls the application:didRegisterForRemoteNotificationsWithDeviceToken: delegate method again to notify you of the change." - Configuring Remote Notification Support, Obtaining a Device Token in iOS and tvOS, Updated: 2017-03-27
     
     - Note: Should this method get called on a token change AND the windmill service is down, the new device WILL NOT be able to retrieve any push notifications until the token changes again or the app calls `UIApplication.shared.registerForRemoteNotifications()` again.
     - Precondition: the account must be stored in the `ApplicationStorage.default` under the `Account.CodingKeys.identifier` key.
     - Seealso: `ApplicationStorage.write(value:key:)` on how to store the account
     - Seealso:
     [Local and Remote Notification Programming Guide]
     (https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/HandlingRemoteNotifications.html#//apple_ref/doc/uid/TP40008194-CH6-SW1)
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        guard case .active(let account, let authorizationToken) = SubscriptionStatus.default else { 
            os_log("No active subscription found. Ensure the account holds a valid subscription prior to allowing to register for notifications", log: .default, type: .debug)
            return
        }

        let tokenString = deviceToken.map { String(format: "%02hhx", $0) }.joined()
        
        self.accountResource.requestDevice(forAccount: account, withToken: tokenString, authorizationToken: authorizationToken) { device, error in
            
            switch error {
            case .some(let error):
                os_log("%{public}@", log: .default, type: .error, error.localizedDescription)
                return
            default:
                os_log("%{public}@", log: .default, type: .debug, device?.debugDescription ?? "")
                return
            }
            
            }.resume()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        os_log("%{public}@", log: .default, type: .error, error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let type = userInfo["type"] as? String, let contentType = APS.ContentType.init(rawValue: type) else {
            completionHandler(.noData)
            return
        }
        
        guard case .export = contentType, case .active(let account, let authorizationToken) = SubscriptionStatus.default else {
            completionHandler(.noData)
            return
        }
        
        self.accountResource.requestExports(forAccount: account, authorizationToken: authorizationToken) { (exports, error) in
            switch (exports, error) {
            case (_, .some(_)):
                completionHandler(.failed)
            case (let exports?, _):
                NotificationCenter.default.post(name: WindmillApp.ContentAvailable, object: WindmillApp.default, userInfo: ["exports": exports])
                completionHandler(.newData)
            case (.none, .none):
                preconditionFailure("Must have either exports returned or an error")
            }
        }.resume()
    }
    
}

