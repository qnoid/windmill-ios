//
//  PurchaseNavigationController.swift
//  windmill
//
//  Created by Markos Charatzas on 18/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class PurchaseNavigationController: UINavigationController {
    
    lazy var _transitioningDelegate: UIViewControllerTransitioningDelegate = SlideInFadeOutControllerTransitioningDelegate()
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = _transitioningDelegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = _transitioningDelegate
    }
}

