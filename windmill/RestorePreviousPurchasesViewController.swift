//
//  RestorePreviousPurchasesViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 28/01/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit
import StoreKit

class RestorePreviousPurchasesViewController: UIViewController {
    
    @IBOutlet var openPurchaseButton: Button! {
        didSet {
            self.openPurchaseButton.isHidden = !SKPaymentQueue.canMakePayments()
        }
    }
    @IBOutlet var restorePreviousPurchasesButton: Button! {
        didSet {
            restorePreviousPurchasesButton.setTitle("", for: .disabled)
        }
    }
    
    @IBOutlet var activityIndicatorViewRestoringPurchases: UIActivityIndicatorView!
    
    
    let subscriptionManager: SubscriptionManager = SubscriptionManager()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestored(notification:)), name: SubscriptionManager.SubscriptionRestored, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestoreFailed(notification:)), name: SubscriptionManager.SubscriptionRestoreFailed, object: subscriptionManager)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestored(notification:)), name: SubscriptionManager.SubscriptionRestored, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestoreFailed(notification:)), name: SubscriptionManager.SubscriptionRestoreFailed, object: subscriptionManager)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SKPaymentQueue.canMakePayments() {
            subscriptionManager.products()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let purchaseOptionsViewController = segue.destination as? PurchaseOptionsViewController else {
            return
        }
        
        purchaseOptionsViewController.subscriptionManager = self.subscriptionManager
    }
    
    @objc func subscriptionRestored(notification: NSNotification) {
        self.performSegue(withIdentifier: "SubscriberUnwind", sender: self)
    }

    @objc func subscriptionRestoreFailed(notification: NSNotification) {
        self.restorePreviousPurchasesButton.isEnabled = true
        self.activityIndicatorViewRestoringPurchases.stopAnimating()
        
        guard let error = notification.userInfo?["error"] as? Error else {
            return
        }
        
        switch error {
        case let error as SubscriptionError:
            let alertController = UIAlertController.Windmill.makeSubscription(error: error)
            self.present(alertController, animated: true, completion: nil)
        default:
            let alertController = UIAlertController.Windmill.make(title: "Error", error: error)
            present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func restorePreviousPurchases() {
        self.restorePreviousPurchasesButton.isEnabled = false
        self.activityIndicatorViewRestoringPurchases.startAnimating()
        self.subscriptionManager.restoreSubscriptions()
    }
}
