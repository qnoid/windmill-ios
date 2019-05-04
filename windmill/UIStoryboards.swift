//
//  UIStoryboards.swift
//  windmill
//
//  Created by Markos Charatzas on 24/10/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    func purchase_instantiateInitialViewController() -> UINavigationController? {
        return self.instantiateInitialViewController() as? UINavigationController
    }
}
