//
//  MainViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 12/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit
import StoreKit

class MainViewController: UIViewController {
    var mainTableViewHeaderView: UITableViewHeaderFooterView {
        
        if case .expired = self.subscriptionStatus {
            return SubscriptionExpiredTableViewFooterView.make(width: tableView.bounds.width)
        } else {
            return MainTableViewHeaderView.make(width: tableView.bounds.width)
        }
    }

    var mainTableViewFooterView: UITableViewHeaderFooterView {
        if case .expired = self.subscriptionStatus {
            return OpenPurchaseOptionsTableViewFooterView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 66.0))
        } else {
            return OpenStoreTableViewFooterView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 66.0))
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet{
            self.tableView.tableHeaderView = self.mainTableViewHeaderView
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.allowsSelection = false
            self.tableView.alwaysBounceVertical = false
            self.tableView.tableFooterView = self.mainTableViewFooterView
        }
    }
    
    var subscriptionStatus = SubscriptionStatus.default
    var subscriptionManager = SubscriptionManager()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch (self.subscriptionStatus, SKPaymentQueue.canMakePayments()) {
        case (.none, true), (.expired, true):
            subscriptionManager.products()
        default:
            break
        }
    }
    
    @objc func subscriptionActive(notification: NSNotification) {
        self.subscriptionStatus = SubscriptionStatus.default
        
        self.performSegue(withIdentifier: "SubscriberUnwind", sender: self)
    }

    @objc func dismiss(_ sender: Any?) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTouchUpInsideOpenPurchaseOptions() {
        
        guard let purchaseOptionsViewController = PurchaseOptionsViewController.make(subscriptionManager: subscriptionManager) else {
            return
        }
        
        purchaseOptionsViewController.navigationItem.leftBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss(_:)))
        
        self.present(UINavigationController(rootViewController: purchaseOptionsViewController), animated: true)
    }

}
