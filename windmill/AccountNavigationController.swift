//
//  AccountNavigationController.swift
//  windmill
//
//  Created by Markos Charatzas on 12/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class AccountNavigationController: UINavigationController {

    static func make(storyboard: UIStoryboard = WindmillApp.Storyboard.main()) -> AccountNavigationController? {
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? AccountNavigationController
    }
}
