//
//  MainTabBarController.swift
//  windmill
//
//  Created by Markos Charatzas on 13/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit
import CloudKit
import os

class MainTabBarController: UITabBarController {

    var mainController: MainController? {
        return self.viewControllers?.first { $0 is MainController } as? MainController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CKContainer.default().accountStatus { accountStatus, error in
            DispatchQueue.main.async {
                self.accountStatus(accountStatus: accountStatus, error: error)
            }
        }
    }
    
    @objc func didBecomeActive(notification: Notification) {
        CKContainer.default().accountStatus { accountStatus, error in
            DispatchQueue.main.async {
                self.accountStatus(accountStatus: accountStatus, error: error)
            }
        }
    }
    
    func accountStatus(accountStatus: CKAccountStatus, error: Error?) {
        
        switch (accountStatus, error) {
        case (.available, nil):
            self.transitionWelcomeViewController(to: AccountNavigationController.make())
        case (.noAccount, nil):
            self.transitionAccountNavigationController(to: WelcomeViewController.make())
        case (.couldNotDetermine, nil):
            os_log("%{public}@", log: .default, type: .debug, "CKAccountStatus: Could not determine status.")
        case (.restricted, nil):
            os_log("%{public}@", log: .default, type: .debug, "CKAccountStatus: Access was denied due to Parental Controls or Mobile Device Management restrictions.")
        case (_, let error?):
            os_log("%{public}@", log: .default, type: .error, "CKAccountStatus error: \(error.localizedDescription)")
        }
    }

    func transitionWelcomeViewController(to: @autoclosure () -> UIViewController?) {
        self.viewControllers = self.viewControllers?.compactMap { viewController in
            switch viewController {
            case is WelcomeViewController:
                return to()
            default:
                return viewController
            }
        }
    }
    
    func transitionAccountNavigationController(to: @autoclosure () -> UIViewController?) {
        self.viewControllers = self.viewControllers?.compactMap { viewController in
            switch viewController {
            case is AccountNavigationController:
                return to()
            default:
                return viewController
            }
        }
    }
}
