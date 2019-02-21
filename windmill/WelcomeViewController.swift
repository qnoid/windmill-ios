//
//  WelcomeViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 11/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    static func make(storyboard: UIStoryboard = WindmillApp.Storyboard.main()) -> WelcomeViewController? {
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? WelcomeViewController
    }
}
