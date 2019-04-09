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


extension Dictionary where Key == AccountViewController.Section, Value == [AccountViewController.Setting] {
    
    typealias Section = AccountViewController.Section
    typealias Setting = AccountViewController.Setting
    typealias Entry = (key: Section, value: [Setting])
    
    func section(for entry: Entry) -> Int? {
        let key = entry.key
        
        guard let index = self.keys.firstIndex(of: key) else {
            return nil
        }

        return self.keys.distance(from: startIndex, to: index)
    }
    
    func row(for setting: Setting, entry: Entry) -> Int? {
        let value = entry.value
        
        guard let index = value.firstIndex(of: setting) else {
            return nil
        }
        
        return index
    }

    func indexPath(for setting: Setting) -> IndexPath? {
        
        guard let entry = self.first(where: { $0.value.contains(setting) }) else {
            return nil
        }
        
        guard let section = self.section(for: entry) else {
            return nil
        }
        
        guard let row = self.row(for: setting, entry: entry) else {
            return nil
        }
        
        return IndexPath(row: row, section: section)
    }
}
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
            self.tableView?.reloadData()
        }
    }

    lazy var sections: [Section: [Setting]] = Section.sections().reduce(into: [Section: [Setting]]()) { sections, section in
        sections[section] = section.settings()
    }
    
    var subscriptionManager = SubscriptionManager()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionPurchased(notification:)), name: SubscriptionManager.SubscriptionPurchased, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestored(notification:)), name: SubscriptionManager.SubscriptionRestored, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionExpired(notification:)), name: SubscriptionManager.SubscriptionExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestoreFailed(notification:)), name: SubscriptionManager.SubscriptionRestoreFailed, object: subscriptionManager)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionPurchased(notification:)), name: SubscriptionManager.SubscriptionPurchased, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestored(notification:)), name: SubscriptionManager.SubscriptionRestored, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionExpired(notification:)), name: SubscriptionManager.SubscriptionExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionFailed(notification:)), name: SubscriptionManager.SubscriptionFailed, object: subscriptionManager)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestoreFailed(notification:)), name: SubscriptionManager.SubscriptionRestoreFailed, object: subscriptionManager)

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
            self.deselect(setting: .refreshSubscription)
        }
    }
    
    @objc func subscriptionRestored(notification: NSNotification) {
        switch SubscriptionStatus.default {
        case .valid(let claim), .expired(_, let claim):
            self.subscribeUser(claim: claim)
        default:
            self.deselect(setting: .refreshSubscription)
        }
    }

    @objc func subscriptionActive(notification: NSNotification) {
        self.subscriptionStatus = SubscriptionStatus.default
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

        guard let indexPath = self.sections.indexPath(for: setting) else {
            return
        }
        
        self.tableView?.delegate?.tableView?(self.tableView, didDeselectRowAt: indexPath)
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
