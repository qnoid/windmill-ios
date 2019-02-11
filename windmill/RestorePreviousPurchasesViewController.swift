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
    
    let subscriptionManager = SubscriptionManager()
    var productsRequest: SKProductsRequest?
    
    let queue: PaymentQueue = PaymentQueue.default
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(restored(notification:)), name: PaymentQueue.restored, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionError(notification:)), name: PaymentQueue.restoreFailedWithError, object: PaymentQueue.default)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector: #selector(restored(notification:)), name: PaymentQueue.restored, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionError(notification:)), name: PaymentQueue.restoreFailedWithError, object: PaymentQueue.default)
    }
    
    override func viewDidLoad() {
        
        if SKPaymentQueue.canMakePayments() {
            self.productsRequest = subscriptionManager.productsRequest()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let purchaseOptionsViewController = segue.destination as? PurchaseOptionsViewController else {
            return
        }
        
        purchaseOptionsViewController.subscriptionManager = subscriptionManager
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func restored(notification: NSNotification) {
        NotificationCenter.default.post(name: Account.isSubscriber, object: self.queue)
    }

    @objc func transactionError(notification: NSNotification) {
        self.restorePreviousPurchasesButton.isEnabled = true
        self.activityIndicatorViewRestoringPurchases.stopAnimating()
        
        guard let error = notification.userInfo?["error"] as? Error else {
            return
        }
        
        switch error {
        case let error as WindmillError:
            let alertController = UIAlertController.Windmill.make(error: error)
            self.present(alertController, animated: true, completion: nil)
        default:
            let alertController = UIAlertController.Windmill.make(title: "Error", error: error)
            present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func restorePreviousPurchases() {
        self.restorePreviousPurchasesButton.isEnabled = false
        self.activityIndicatorViewRestoringPurchases.startAnimating()
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
