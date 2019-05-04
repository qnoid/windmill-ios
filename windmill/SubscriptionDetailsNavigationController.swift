//
//  SubscriptionDetailsNavigationController.swift
//  windmill
//
//  Created by Markos Charatzas on 03/05/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class SubscriptionDetailsNavigationController: UINavigationController {
    
    class func make(storyboard: UIStoryboard = WindmillApp.Storyboard.subscriber()) -> SubscriptionDetailsNavigationController? {
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? SubscriptionDetailsNavigationController
        
        return viewController
    }    
}
