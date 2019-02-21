//
//  SlideInFadeOutControllerTransitioningDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 13/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class CustomPresentationController: UIPresentationController {
    
    override var shouldPresentInFullscreen: Bool {
        return true
    }
    
    override var shouldRemovePresentersView: Bool {
        return true
    }
}

class SlideInViewControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        
        let containerView = transitionContext.containerView
        let from = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let to = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        containerView.addSubview(to)
        
        to.frame = containerView.frame.offsetBy(dx: 0, dy: to.frame.height)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            from.transform = CATransform3DGetAffineTransform(CATransform3DMakeScale(0.9, 0.9, 1.0)) //CATransform3DGetAffineTransform(CATransform3DMakeScale(1.0, 1.0, 1.0))
            to.frame = containerView.bounds
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class FadeOutViewControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let from = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let to = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        containerView.addSubview(to)
        containerView.bringSubviewToFront(from)
        
        to.transform = CATransform3DGetAffineTransform(CATransform3DMakeScale(0.9, 0.9, 1.0))
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            to.transform = transitionContext.targetTransform
            from.frame = containerView.frame.offsetBy(dx: 0, dy: to.frame.height)
        }) { finished in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

class SlideInFadeOutControllerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInViewControllerAnimatedTransitioning()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeOutViewControllerAnimatedTransitioning()
    }
    
}
