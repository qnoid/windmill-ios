//
//  MainTabBarController.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 13/02/2019.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
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
        @unknown default:
            return
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
