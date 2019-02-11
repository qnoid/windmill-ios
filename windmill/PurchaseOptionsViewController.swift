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
    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var purchaseButton: Button! {
        didSet {
            purchaseButton.setTitle("", for: .disabled)
        }
    }
    
    @IBOutlet var activityIndicatorViewSubscribe: UIActivityIndicatorView!
    
    let subscriptionLabelTitle = "Auto Renewable Subscription\n %@"
    
    var subscriptionManager: SubscriptionManager? {
        didSet {
            self.subscriptionManager?.delegate = self
        }
    }
    
    let queue: PaymentQueue = PaymentQueue.default
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(purchasing(notification:)), name: PaymentQueue.purchasing, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(purchased(notification:)), name: PaymentQueue.purchased, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionError(notification:)), name: PaymentQueue.transactionError, object: PaymentQueue.default)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(purchasing(notification:)), name: PaymentQueue.purchasing, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(purchased(notification:)), name: PaymentQueue.purchased, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionError(notification:)), name: PaymentQueue.transactionError, object: PaymentQueue.default)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let product = self.subscriptionManager?.products?.first( where: SubscriptionManager.Product.isIndividualMonthly) {
            self.updateView(product: product)
        }
    }
    
    @IBAction func didTouchUpInsideHelp(_ sender: Any) {
        
    }
    
    fileprivate func updateView(product: SKProduct?) {
        self.subscriptionLabel.text = String(format: self.subscriptionLabelTitle, product?.localizedTitle ?? "")
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product?.priceLocale
        
        let formattedString = formatter.string(from: product?.price ?? 0.0) ?? ""
        
        self.purchaseButton.setTitle(String(format: "Subscribe for %@ a \(SubscriptionManager.Product.individualMonthly.duration)", formattedString), for: .normal)
    }
    
    func success(_ manager: SubscriptionManager, products: [SKProduct]) {
        updateView(product: products.first)
    }
    
    func error(_ manager: SubscriptionManager, didFailWithError error: Error) {
        let alertController = UIAlertController.Windmill.make(title: "Error", error: error)
        present(alertController, animated: true, completion: nil)
    }

    @objc func purchasing(notification: NSNotification) {
        self.purchaseButton.isEnabled = false
        self.activityIndicatorViewSubscribe.startAnimating()
    }
    
    @objc func purchased(notification: NSNotification) {
        NotificationCenter.default.post(name: Account.isSubscriber, object: self.queue)
    }
    
    @objc func transactionError(notification: NSNotification) {
        self.purchaseButton?.isEnabled = true
        self.activityIndicatorViewSubscribe?.stopAnimating()
        
        guard let error = notification.userInfo?["error"] as? Error else {
            return
        }
        
        switch error {
        case let error as SKError where error.code == SKError.paymentCancelled:
            return
        case let error as WindmillError:
            let alertController = UIAlertController.Windmill.make(error: error)
            self.present(alertController, animated: true, completion: nil)
        default:
            let alertController = UIAlertController.Windmill.make(title: "Error", error: error)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func purchase(_ sender: Any) {
        
        guard let product = self.subscriptionManager?.products?.first( where: SubscriptionManager.Product.isIndividualMonthly) else {
            return
        }
        
        let payment = SKPayment(product: product)
        self.queue.add(payment)
    }
}
