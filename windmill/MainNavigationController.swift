//
//  MainNavigationViewController.swift
//  IntegrationTests
//
//  Created by Markos Charatzas on 31/01/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit
import os

class MainNavigationPresentationController: UIPresentationController {
    
    override var shouldPresentInFullscreen: Bool {
        return true
    }
    
    override var shouldRemovePresentersView: Bool {
        return true
    }
}

class PresentedMainViewControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        

        let containerView = transitionContext.containerView
        let from = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let to = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        containerView.addSubview(to)
        containerView.bringSubviewToFront(from)
        
        let transform3D = CATransform3DMakeScale(0.9, 0.9, 1.0)
        to.transform = CATransform3DGetAffineTransform(transform3D)
                
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            to.transform = transitionContext.targetTransform //CATransform3DGetAffineTransform(CATransform3DMakeScale(1.0, 1.0, 1.0))
            from.frame = from.frame.offsetBy(dx: 0, dy: from.frame.height)
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class DismissedMainViewControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let from = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let to = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        containerView.addSubview(to)
        
        to.frame = to.frame.offsetBy(dx: 0, dy: to.frame.height)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            from.transform = CATransform3DGetAffineTransform(CATransform3DMakeScale(0.9, 0.9, 1.0))
            to.frame = containerView.bounds
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class MainNavigationControllerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return MainNavigationPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentedMainViewControllerAnimatedTransitioning()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissedMainViewControllerAnimatedTransitioning()
    }

}

class MainNavigationController: UINavigationController {
    
}
