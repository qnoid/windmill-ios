//
//  AccountViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 11/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit
import CloudKit
import StoreKit

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
            }
        }
        
        case subscription = "Subscription"
        case store = "Windmill Store"
        
        func settings(for status: SubscriptionStatus = SubscriptionStatus.default) -> [Setting] {
            switch (self, status) {
            case (.subscription, .active):
                return [.subscription, .refreshSubscription]
            case (.subscription, .expired):
                return [.refreshSubscription]
            case (.subscription, .none):
                return [.refreshSubscription, .restorePurchases]
            case (.store, .expired), (.store, .none):
                return [.purchaseOptions]
            case (.store, .active):
                return []
            }
        }
    }
    
    enum Setting: String, CodingKey {
        static var allValues: [Setting] = [.subscription, .refreshSubscription, .restorePurchases, .purchaseOptions]
        
        case subscription = "Individual Monthly"
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

    var subscriptionStatus: SubscriptionStatus = SubscriptionStatus.default {
        didSet {
            self.tableView?.reloadData()
        }
    }

    lazy var sections: [Section: [Setting]] = Section.sections().reduce(into: [Section: [Setting]]()) { sections, section in
        sections[section] = section.settings()
    }
    
    var subscriptionManager = SubscriptionManager()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionExpired(notification:)), name: SubscriptionManager.SubscriptionExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestoreFailed(notification:)), name: SubscriptionManager.SubscriptionRestoreFailed, object: subscriptionManager)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionExpired(notification:)), name: SubscriptionManager.SubscriptionExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestoreFailed(notification:)), name: SubscriptionManager.SubscriptionRestoreFailed, object: subscriptionManager)

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
    
    @objc func subscriptionActive(notification: NSNotification) {
        self.subscriptionStatus = SubscriptionStatus.default
        
        CKContainer.default().fetchUserRecordID { (id, error) in
            debugPrint("\(#function), id:\(String(describing: id?.recordName))")
        }
    }
    
    @objc func subscriptionExpired(notification: NSNotification) {
        self.subscriptionStatus = SubscriptionStatus.default
    }


    @objc func subscriptionFailed(notification: NSNotification) {
        self.subscriptionStatus = SubscriptionStatus.default
        
        guard let error = notification.userInfo?["error"] as? Error else {
            return
        }
        
        self.error(self.subscriptionManager, didFailWithError: error)
    }

    @objc func subscriptionRestoreFailed(notification: NSNotification) {
        
        self.deselect(setting: Setting.restorePurchases)
        
        guard let error = notification.userInfo?["error"] as? Error else {
            return
        }

        self.error(self.subscriptionManager, didFailWithError: error)
    }
    
    func deselect(setting: AccountViewController.Setting) {

        let entry = self.sections.first(where: { $0.value.contains(setting) })
        
        guard let key = entry?.key, let section = Section.sections().index(of: key) else {
            return
        }
        
        guard let value = entry?.value, let row = value.index(of: setting) else {
            return
        }

        self.tableView?.delegate?.tableView?(self.tableView, didDeselectRowAt: IndexPath(row: row, section: section))
    }

    func cell(_ cell: UITableViewCell, for setting: Setting) {
        switch setting {
        case .subscription:
            cell.accessoryType = .detailButton
        case .refreshSubscription, .restorePurchases:
            cell.accessoryView = UIActivityIndicatorView(style: .gray)
        default:
            return
        }
    }

    func accessoryButtonTapped(setting: Setting) {
        guard let subscriptionDetailsViewController = SubscriptionDetailsViewController.make() else {
            return
        }
        
        self.show(subscriptionDetailsViewController, sender: self)
    }
    
    func didSelect(setting: Setting) {
        switch setting {
        case .subscription:
            guard let manageSubscriptionsURL = URL(string: "itms-apps://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions") else {
                return
            }
            UIApplication.shared.open(manageSubscriptionsURL, options: [:], completionHandler: nil)
        case .refreshSubscription:
            self.subscriptionManager.refreshReceipt()
        case .restorePurchases:
            self.subscriptionManager.restoreSubscriptions()
        case .purchaseOptions:
            guard let initialViewController = PurchaseOptionsViewController.make(subscriptionManager: subscriptionManager) else {
                return
            }
            
            self.show(initialViewController, sender: self)
        }
    }
    
    func success(_ manager: SubscriptionManager, receipt: URL) {
        guard let rawReceiptData = try? Data(contentsOf: receipt) else {
            return
        }
        
        let receiptData = rawReceiptData.base64EncodedString()
        
        self.subscriptionManager.restoreSubscription(receiptData: receiptData)
    }
    
    func error(_ manager: SubscriptionManager, didFailWithError error: Error) {
        self.deselect(setting: Setting.refreshSubscription)

        switch error {
        case let error as SKError where error.code == SKError.paymentCancelled:
            return
        case let error as SubscriptionError:
            let alertController = UIAlertController.Windmill.make(error: error)
            present(alertController, animated: true, completion: nil)
        default:
            let alertController = UIAlertController.Windmill.make(title: "Error", error: error)
            present(alertController, animated: true, completion: nil)
        }
    }
}
