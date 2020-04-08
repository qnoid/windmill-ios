//
//  MainController.swift
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
import os

class MainController: UIViewController {
    
    var mainNavigationController: MainNavigationController? {
        return self.children.first{ $0 is MainNavigationController } as? MainNavigationController
    }

    var appsNavigationController: AppsNavigationController? {
        return self.children.first{ $0 is AppsNavigationController } as? AppsNavigationController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        if SubscriptionStatus.default.isActive, let appsNavigationController = AppsNavigationController.make() {
            self.addChild(appsNavigationController)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if SubscriptionStatus.default.isActive, let appsNavigationController = AppsNavigationController.make() {
            self.addChild(appsNavigationController)
        }
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        self.children.forEach { child in
            if let restorationIdentifier = child.restorationIdentifier {
                coder.encode(child, forKey: restorationIdentifier)
            }
        }
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        if let appsNavigationController = coder.decodeObject(of: [AppsNavigationController.self], forKey: AppsNavigationController.restorationIdentifier) as? AppsNavigationController {
            self.addChild(appsNavigationController)
        }
    }

    override func viewDidLayoutSubviews() {
        self.tabBarItem.title = self.children.first?.title
        self.tabBarItem.image = self.children.first?.tabBarItem.image

        switch (self.mainNavigationController, self.appsNavigationController) {
        case (let mainNavigationController?, let appsNavigationController?):
            self.switch(source: mainNavigationController, destination: appsNavigationController)
        default:
            break
        }        
    }
    
    /**
     Prior to calling this method, you must ensure that both `UIViewController` `source` and `destination` are children of `MainController`.
     
     e.g.
        `self.addChild(destination)`
        `self.switch(source: source, destination: destination)`
     
     - Parameters:
        - source: the `UIViewController` to switch from
        - param: destination the `UIViewController` to switch to
     - Precondition: the given `destination` UIViewController must be a child of this container controller
     */
    func `switch`(source: UIViewController, destination: UIViewController) {
        
        source.willMove(toParent: nil)
        
        destination.view.frame = self.view.bounds
        self.view.addSubview(destination.view)

        source.view.removeFromSuperview()
        source.removeFromParent()
        
        destination.didMove(toParent: self)
    }

    func transition(from: UIViewController, to: UIViewController) {
        from.willMove(toParent: nil)
        self.addChild(to)
        
        self.transition(from: from, to: to, duration: self.transitionCoordinator?.transitionDuration ?? 0.4, options: [], animations: {
            
        }) { (finished) in
            from.removeFromParent()
            to.didMove(toParent: self)
        }
    }
    
    @IBAction @objc func unwindToMainTabBarController(_ segue: UIStoryboardSegue) {}
    
    @IBAction func unwindToSubscriber(_ segue: UIStoryboardSegue) {
        
        switch segue.source.presentingViewController {
        case is MainTabBarController:
            if let appsNavigationController = AppsNavigationController.make() {
                transitionAppsNavigationController(appsNavigationController)
            }
        default:
            if let appsNavigationController = AppsNavigationController.make() {
                self.displayAppsNavigationController(appsNavigationController)
            }
            break
        }
    }
    
    func transitionAppsNavigationController(_ to: AppsNavigationController) {
        if let mainNavigationController = self.mainNavigationController {
            self.transition(from: mainNavigationController, to: to)
        }
    }
    
    @IBAction func displayAppsNavigationController() {
        if let appsNavigationController = AppsNavigationController.make() {
            self.displayAppsNavigationController(appsNavigationController)
        }
    }
    
    func displayAppsNavigationController(_ destination: AppsNavigationController) {
        if let mainNavigationController = self.mainNavigationController {
            self.addChild(destination)
            self.switch(source: mainNavigationController, destination: destination)
        }
    }
}
