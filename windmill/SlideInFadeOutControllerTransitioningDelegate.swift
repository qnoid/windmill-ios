//
//  SlideInFadeOutControllerTransitioningDelegate.swift
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
