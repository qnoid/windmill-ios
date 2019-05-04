//
//  AppsNavigationController.swift
//  windmill
//
//  Created by Markos Charatzas on 31/01/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class AppsNavigationController: UINavigationController {
    
    static let restorationIdentifier: String = "AppsNavigationController"
    
    static func make(storyboard: UIStoryboard = WindmillApp.Storyboard.subscriber()) -> AppsNavigationController? {
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? AppsNavigationController
    }    
}
