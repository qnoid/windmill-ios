//
//  ProductsStoreViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 23/1/19.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit
import StoreKit
import Alamofire

class PurchaseOptionsViewController: UIViewController, SubscriptionManagerDelegate  {
    
    class func make(subscriptionManager: SubscriptionManager, for account: String? = nil, storyboard: UIStoryboard = WindmillApp.Storyboard.purchase()) -> PurchaseOptionsViewController? {
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? PurchaseOptionsViewController
        viewController?.subscriptionManager = subscriptionManager
        
        return viewController
    }

    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var youAreOnTrialLabel: UILabel!
    @IBOutlet weak var purchaseButton: Button! {
        didSet {
            purchaseButton.setTitle("", for: .disabled)
        }
    }
    
    @IBOutlet var activityIndicatorViewSubscribe: UIActivityIndicatorView!
    
    let subscriptionLabelTitle = "Auto Renewable Subscription\n %@"
    
    weak var subscriptionManager: SubscriptionManager? {
        didSet {
            subscriptionManager?.delegate = self
        }
    }
    
    var product: SKProduct? {
        didSet {
            self.purchaseButton?.isEnabled = true
            if let product = product {
                updateView(product: product)
            } else {
                self.activityIndicatorViewSubscribe?.stopAnimating()
                self.purchaseButton?.setTitle("Refresh", for: .normal)
            }
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionPurchasing(notification:)), name: SubscriptionManager.SubscriptionPurchasing, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionPurchased(notification:)), name: SubscriptionManager.SubscriptionPurchased, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(receiptRefreshing(notification:)), name: PaymentQueue.ReceiptRefreshing, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(receiptRefreshed(notification:)), name: PaymentQueue.ReceiptRefreshed, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(receiptRefreshFailed(notification:)), name: PaymentQueue.ReceiptRefreshFailed, object: PaymentQueue.default)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionPurchasing(notification:)), name: SubscriptionManager.SubscriptionPurchasing, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionPurchased(notification:)), name: SubscriptionManager.SubscriptionPurchased, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(receiptRefreshing(notification:)), name: PaymentQueue.ReceiptRefreshing, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(receiptRefreshed(notification:)), name: PaymentQueue.ReceiptRefreshed, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(receiptRefreshFailed(notification:)), name: PaymentQueue.ReceiptRefreshFailed, object: PaymentQueue.default)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.purchaseButton.isEnabled = false
        self.activityIndicatorViewSubscribe.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.product = self.subscriptionManager?.products?.first(where: SubscriptionManager.Product.isDistributionMonthly)
    }
    
    @IBAction func didTouchUpInsideHelp(_ sender: Any) {
        
    }
    
    fileprivate func updateView(product: SKProduct?) {
        self.activityIndicatorViewSubscribe?.stopAnimating()
        self.subscriptionLabel?.text = String(format: self.subscriptionLabelTitle, product?.localizedTitle ?? "")
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product?.priceLocale
        
        let formattedString = formatter.string(from: product?.price ?? 0.0) ?? ""
        
        self.purchaseButton?.setTitle(String(format: "Subscribe for %@ a \(SubscriptionManager.Product.distributionMonthly.duration)", formattedString), for: .normal)
    }
    
    func success(_ manager: SubscriptionManager, products: [SKProduct]) {
        self.product = products.first
    }
    
    func error(_ manager: SubscriptionManager, didFailWithError error: Error) {
        self.product = nil

        let alertController = UIAlertController.Windmill.make(title: "Error", error: error)
        present(alertController, animated: true, completion: nil)
    }

    @objc func subscriptionPurchasing(notification: NSNotification) {
        self.purchaseButton?.isEnabled = false
        self.activityIndicatorViewSubscribe.startAnimating()
    }
    
    @objc func subscriptionPurchased(notification: NSNotification) {
        self.product = nil
        self.performSegue(withIdentifier: "SubscriberUnwind", sender: self)
    }
    
    @objc func subscriptionFailed(notification: NSNotification) {
        self.purchaseButton?.isEnabled = true
        self.activityIndicatorViewSubscribe?.stopAnimating()
        
        guard let error = notification.userInfo?["error"] as? Error else {
            return
        }
        
        switch error {
        case let error as SKError where error.code == SKError.paymentCancelled:
            return
        case let error as SubscriptionError where error.isOutdated:
            let alertController = UIAlertController.Windmill.makeSubscription(error: error)
            alertController.addAction(UIAlertAction(title: "Refresh Receipt", style: .default) { action in
                PaymentQueue.default.refreshReceipt()
            })
            self.present(alertController, animated: true, completion: nil)
        case let error as SubscriptionError:
            let alertController = UIAlertController.Windmill.makeSubscription(error: error)
            self.present(alertController, animated: true, completion: nil)
        default:
            let alertController = UIAlertController.Windmill.make(title: "Error", error: error)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func receiptRefreshing(notification: NSNotification) {
        self.purchaseButton?.isEnabled = false
        self.activityIndicatorViewSubscribe.startAnimating()
    }

    @objc func receiptRefreshFailed(notification: NSNotification) {
        self.purchaseButton?.isEnabled = true
        self.activityIndicatorViewSubscribe?.stopAnimating()
    }
    
    @objc func receiptRefreshed(notification: NSNotification) {
        guard let receipt = notification.userInfo?["receipt"] as? String else {
            return
        }
        
        self.subscriptionManager?.restoreSubscription(receiptData: receipt)
    }

    @IBAction func purchase(_ sender: Any) {

        guard let product = self.product else {
            
            self.subscriptionManager?.products()
            self.purchaseButton?.isEnabled = false
            self.activityIndicatorViewSubscribe.startAnimating()
            
            return
        }
        
        self.subscriptionManager?.purchase(product)
    }
}
