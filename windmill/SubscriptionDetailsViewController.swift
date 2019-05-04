//
//  SubscriptionDetailsViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 19/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class SubscriptionDetailsViewController: UIViewController {

    class func make(storyboard: UIStoryboard = WindmillApp.Storyboard.subscriber()) -> SubscriptionDetailsViewController? {
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? SubscriptionDetailsViewController
        
        return viewController
    }
    
    @IBOutlet weak var subscriptionLabel: UILabel!
    
    @IBAction func didTouchUpInsideManager(_ sender: Any) {
        
        guard let manageSubscriptionsURL = URL(string: "itms-apps://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions") else {
            return
        }
        UIApplication.shared.open(manageSubscriptionsURL, options: [:], completionHandler: nil)
    }
}
