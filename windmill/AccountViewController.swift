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
        static var allValues: [Section] = [.subscription]
        
        case subscription = "Subscription"
    }
    
    enum Setting: String, CodingKey {
        static var allValues: [Setting] = [.subscription, .refreshSubscription, .restorePurchases]
        
        case subscription = "Individual Monthly"
        case refreshSubscription = "Refresh Subscription"
        case restorePurchases = "Restore Purchases"
        
        static func settings(for status: SubscriptionStatus) -> [Setting] {
            switch status {
            case .active:
                return [.subscription, .refreshSubscription, .restorePurchases]
            case .none:
                return [.refreshSubscription, .restorePurchases]
            }
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet{
            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AccountTableViewCell")
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.dataSource = self.dataSource
            self.tableView.delegate = self.delegate
            self.tableView.alwaysBounceVertical = false
            self.tableView.tableFooterView = UITableViewHeaderFooterView()
        }
    }

    var dataSource = AccountTableViewDataSource(settings: []) {
        didSet {
            dataSource.controller = self
            self.tableView?.dataSource = dataSource
        }
    }
    
    var delegate = AccountTableViewDelegate(settings: []) {
        didSet {
            delegate.controller = self
            self.tableView.delegate = delegate
        }
    }
    
    var subscriptionStatus: SubscriptionStatus? {
        didSet {
            if oldValue == nil, let subscriptionStatus = subscriptionStatus {
                self.subscriptionStatus(subscriptionStatus)
            }
            
            if let subscriptionStatus = subscriptionStatus {
                self.dataSource = AccountTableViewDataSource(settings: Setting.settings(for: subscriptionStatus))
                self.delegate = AccountTableViewDelegate(settings: Setting.settings(for: subscriptionStatus))
                self.tableView?.reloadData()
            }
        }
    }

    var receiptRefreshRequest: SKReceiptRefreshRequest?
    
    var subscriptionManager = SubscriptionManager()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.subscriptionManager.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestoreFailed(notification:)), name: SubscriptionManager.SubscriptionRestoreFailed, object: subscriptionManager)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.subscriptionManager.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestoreFailed(notification:)), name: SubscriptionManager.SubscriptionRestoreFailed, object: subscriptionManager)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscriptionStatus = SubscriptionStatus.shared
    }
    
    func subscriptionStatus(_ subscriptionStatus: SubscriptionStatus) {
        CKContainer.default().fetchUserRecordID { (id, error) in
            debugPrint("\(#function), id:\(String(describing: id?.recordName))")
        }
    }
    
    
    @objc func subscriptionActive(notification: NSNotification) {
        self.subscriptionStatus = SubscriptionStatus.shared
    }

    @objc func subscriptionRestoreFailed(notification: NSNotification) {        
        self.deselect(setting: Setting.restorePurchases)
        
        guard let error = notification.userInfo?["error"] as? Error else {
            return
        }

        self.error(self.subscriptionManager, didFailWithError: error)
    }
    
    func deselect(setting: AccountViewController.Setting) {
        guard let index = self.dataSource.settings.index(of: setting) else {
            return
        }
        
        self.tableView.delegate?.tableView?(self.tableView, didDeselectRowAt: IndexPath(row: index, section: 0))
    }

    func cell(_ cell: UITableViewCell, for setting: Setting) {
        switch setting {
        case .subscription:
            cell.accessoryType = .detailButton
        default:
            cell.accessoryView = UIActivityIndicatorView(style: .gray)
            //cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
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
            self.receiptRefreshRequest = self.subscriptionManager.receiptRefreshRequest()            
        case .restorePurchases:
            self.subscriptionManager.restoreSubscriptions()
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
        case let error as SubscriptionError:
            let alertController = UIAlertController.Windmill.make(error: error)
            self.present(alertController, animated: true, completion: nil)
        default:
            let alertController = UIAlertController.Windmill.make(title: "Error", error: error)
            present(alertController, animated: true, completion: nil)
        }
    }
}
