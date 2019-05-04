//
//  AccountViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 11/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit
import StoreKit
import os


/**
    The AccountViewController guarantees that a user has logged in their Apple ID and has iCloud Drive for Windmill turned on.
 
 - precondition: to show this view controller, make sure that the user is logged in their Apple ID and has iCloud Drive for Windmill turned on.
 */
class AccountViewController: UIViewController, SubscriptionManagerDelegate {

    enum Section: String, CodingKey {
        static var allValues: [Section] = [.subscription, .store]
        
        static func sections(for status: SubscriptionStatus = SubscriptionStatus.default) -> [Section] {
            switch status {
            case .active:
                return [.subscription]
            case .expired, .none:
                return [.subscription, .store]
            case .valid:
                return []
            }
        }
        
        case subscription = "Subscription"
        case store = "Windmill Store"
        
        func settings(for status: SubscriptionStatus = SubscriptionStatus.default) -> [Setting] {
            switch (self, status) {
            case (.subscription, .active):
                return [.subscription, .refreshSubscription]
            case (.subscription, .expired), (.subscription, .valid):
                return [.refreshSubscription]
            case (.subscription, .none):
                return [.refreshSubscription, .restorePurchases]
            case (.store, .expired), (.store, .none):
                return [.purchaseOptions]
            case (.store, .active), (.store, .valid):
                return []
            }
        }
    }
    
    enum Setting: String, CodingKey {
        static var allValues: [Setting] = [.subscription, .refreshSubscription, .restorePurchases, .purchaseOptions]
        
        case subscription = "Distribution Monthly"
        case refreshSubscription = "Refresh Subscription"
        case restorePurchases = "Restore Purchases"
        case purchaseOptions = "Open Purchase Options"        
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet{
            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AccountTableViewCell")
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.alwaysBounceVertical = false
            self.tableView.tableFooterView = UITableViewHeaderFooterView()
        }
    }
    @IBOutlet weak var tableViewDataSource: AccountTableViewDataSource! {
        didSet{
            tableViewDataSource?.subscriptionStatus = SubscriptionStatus.default
        }
    }
    @IBOutlet weak var tableViewDelegate: AccountTableViewDelegate! {
        didSet{
            tableViewDelegate?.subscriptionStatus = SubscriptionStatus.default
        }
    }
    
    var subscriptionStatus = SubscriptionStatus.default {
        didSet {
            self.tableViewDataSource?.subscriptionStatus = subscriptionStatus
            self.tableViewDelegate?.subscriptionStatus = subscriptionStatus
            self.sections = Section.sections(for: subscriptionStatus)
            self.tableView?.reloadData()
        }
    }

    var sections = Section.sections(for: SubscriptionStatus.default)
    
    var subscriptionManager = SubscriptionManager()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionPurchased(notification:)), name: SubscriptionManager.SubscriptionPurchased, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestored(notification:)), name: SubscriptionManager.SubscriptionRestored, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionExpired(notification:)), name: SubscriptionManager.SubscriptionExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestoreFailed(notification:)), name: SubscriptionManager.SubscriptionRestoreFailed, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(receiptRefreshing(notification:)), name: PaymentQueue.ReceiptRefreshing, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(receiptRefreshed(notification:)), name: PaymentQueue.ReceiptRefreshed, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(receiptRefreshFailed(notification:)), name: PaymentQueue.ReceiptRefreshFailed, object: PaymentQueue.default)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionPurchased(notification:)), name: SubscriptionManager.SubscriptionPurchased, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestored(notification:)), name: SubscriptionManager.SubscriptionRestored, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionExpired(notification:)), name: SubscriptionManager.SubscriptionExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestoreFailed(notification:)), name: SubscriptionManager.SubscriptionRestoreFailed, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(receiptRefreshing(notification:)), name: PaymentQueue.ReceiptRefreshing, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(receiptRefreshed(notification:)), name: PaymentQueue.ReceiptRefreshed, object: PaymentQueue.default)
        NotificationCenter.default.addObserver(self, selector: #selector(receiptRefreshFailed(notification:)), name: PaymentQueue.ReceiptRefreshFailed, object: PaymentQueue.default)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch (self.subscriptionStatus) {
        case .valid(let claim), .expired(_, let claim):
            self.subscribeUser(claim: claim)
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subscriptionManager.delegate = self

        switch (self.subscriptionStatus, SKPaymentQueue.canMakePayments()) {
        case (.none, true), (.expired, true):
             subscriptionManager.products()
        default:
            break
        }
    }
    
    private func subscribeUser(manager: CloudKitManager = CloudKitManager.shared, claim: SubscriptionClaim) {
        
        let container = manager.container
        
        guard let containerIdentifier = container.containerIdentifier else {
            os_log("CKContainer.containerIdentifier returned null. Will not procceed with subscribing user. This is a critical error and should be investigated further.", log: .default, type: .error)
            return
        }
        
        container.fetchUserRecordID { [weak self, subscriptionManager = self.subscriptionManager] (user, error) in
            
            switch(user, error){
            case(let user?, _):
                self?.subscriptionManager.subscribe(user: user.recordName, container: containerIdentifier, claim: claim) { (account, token, error) in                    
                    switch(account, error) {
                    case(let account?, _):
                        self?.subscriptionManager.share(account: account, claim: claim)
                    case(_, let error?):
                        self?.error(subscriptionManager, didFailWithError: error)
                    case (.none, .none):
                        preconditionFailure("SubscriptionManager.subscribe must callback with either an account/token or an error")
                    }
                }
            case(_, let error?):
                os_log("There was an error while fetching the user record: '%{public}@'", log: .default, type: .error, error.localizedDescription)
            case (.none, .none):
                preconditionFailure("CKContainer.fetchUserRecordID must call with either a user record or an error")
            }
        }
    }
    
    @objc func subscriptionPurchased(notification: NSNotification) {
        switch SubscriptionStatus.default {
        case .valid(let claim), .expired(_, let claim):
            self.subscribeUser(claim: claim)
        default:
            self.deselect(section: .subscription, setting: .refreshSubscription)
        }
    }
    
    @objc func subscriptionRestored(notification: NSNotification) {
        switch SubscriptionStatus.default {
        case .valid(let claim), .expired(_, let claim):
            self.subscribeUser(claim: claim)
        default:
            self.deselect(section: .subscription, setting: .refreshSubscription)
        }
    }

    @objc func subscriptionActive(notification: NSNotification) {
        self.subscriptionStatus = SubscriptionStatus.default
    }
    
    @objc func subscriptionExpired(notification: NSNotification) {
        self.subscriptionStatus = SubscriptionStatus.default
    }

    @objc func subscriptionFailed(notification: NSNotification) {
        self.deselect(section: .subscription, setting: .refreshSubscription)
        self.subscriptionStatus = SubscriptionStatus.default
        
        guard let error = notification.userInfo?["error"] as? Error else {
            return
        }
        
        self.error(self.subscriptionManager, didFailWithError: error)
    }

    @objc func subscriptionRestoreFailed(notification: NSNotification) {
        self.deselect(section: .subscription, setting: .refreshSubscription)
        self.deselect(section: .subscription, setting: .restorePurchases)
        
        guard let error = notification.userInfo?["error"] as? Error else {
            return
        }

        self.error(self.subscriptionManager, didFailWithError: error)
    }
    
    func deselect(section: Section, setting: AccountViewController.Setting) {
        guard let indexPath = self.tableViewDataSource.indexPath(for: section, setting: setting), let tableView = self.tableView else {
            return
        }
        
        self.tableViewDelegate?.tableView(tableView, didDeselectRowAt: indexPath)
    }

    func accessoryButtonTapped(setting: Setting, cell: UITableViewCell) {
        
        switch setting {
        case .subscription:
            guard let subscriptionDetailsNavigationController = SubscriptionDetailsNavigationController.make() else {
                return
            }
            
            present(subscriptionDetailsNavigationController, animated: true)
        case .refreshSubscription:
            let alertController = UIAlertController.Windmill.makeSubscription(error: SubscriptionError.expired)
            alertController.addAction(UIAlertAction(title: "Refresh Subscription", style: .default) { action in
                cell.accessoryView = UIActivityIndicatorView(style: .gray)
                PaymentQueue.default.refreshReceipt()
            })
            present(alertController, animated: true, completion: nil)
        default:
            return
        }
    }
    
    func didSelect(setting: Setting) {
        switch setting {
        case .subscription:
            guard let manageSubscriptionsURL = URL(string: "itms-apps://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions") else {
                return
            }
            UIApplication.shared.open(manageSubscriptionsURL, options: [:], completionHandler: nil)
        case .refreshSubscription:
            PaymentQueue.default.refreshReceipt()
        case .restorePurchases:
            self.subscriptionManager.restoreSubscriptions()
        case .purchaseOptions:
            guard let initialViewController = PurchaseOptionsViewController.make(subscriptionManager: subscriptionManager) else {
                return
            }
            
            self.show(initialViewController, sender: self)
        }
    }
    
    @objc func receiptRefreshing(notification: NSNotification) {
        guard let indexPath = self.tableViewDataSource.indexPath(section: .subscription, setting: .refreshSubscription) else {
            return
        }
        
        self.tableViewDelegate.animateActivityIndicatorView(tableView, at: indexPath)
    }
    
    @objc func receiptRefreshed(notification: NSNotification) {
        guard let receipt = notification.userInfo?["receipt"] as? String else {
            return
        }
        
        self.subscriptionManager.restoreSubscription(receiptData: receipt)
    }

    @objc func receiptRefreshFailed(notification: NSNotification) {
        self.deselect(section: .subscription, setting: .refreshSubscription)
        
        guard let error = notification.userInfo?["error"] as? Error else {
            return
        }
        
        let alertController = UIAlertController.Windmill.make(title: "Error", error: error)
        present(alertController, animated: true, completion: nil)
    }
    
    func error(_ manager: SubscriptionManager, didFailWithError error: Error) {

        switch error {
        case let error as SKError where error.code == SKError.paymentCancelled:
            return
        case let error as SubscriptionError where error.isExpired:
            guard let indexPath = self.tableViewDataSource.indexPath(for: .subscription, setting: .refreshSubscription) else {
                return
            }
            
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryView = nil
            cell?.accessoryType = .detailButton
            return
        case let error as SubscriptionError:
            let alertController = UIAlertController.Windmill.makeSubscription(error: error)
            present(alertController, animated: true, completion: nil)
        default:
            let alertController = UIAlertController.Windmill.make(title: "Error", error: error)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction @objc func unwindToAccountViewController(_ segue: UIStoryboardSegue) {
        
    }

}
