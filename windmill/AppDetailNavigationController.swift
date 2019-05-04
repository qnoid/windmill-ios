//
//  AppDetailNavigationController.swift
//  windmill
//
//  Created by Markos Charatzas on 03/05/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class AppDetailNavigationController: UINavigationController {
    
    static let restorationIdentifier: String = "AppDetailNavigationController"
    
    static func make(export: Export, storyboard: UIStoryboard = WindmillApp.Storyboard.subscriber()) -> AppDetailNavigationController? {
        let appDetailNavigationController = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? AppDetailNavigationController
        
        let appDetailViewController = appDetailNavigationController?.topViewController as? AppDetailViewController
        appDetailViewController?.export = export
        
        return appDetailNavigationController
    }
}
