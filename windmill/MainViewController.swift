//
//  MainViewController.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 12/02/2019.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
//

import UIKit
import StoreKit

class MainViewController: UIViewController {
    var mainTableViewHeaderView: UITableViewHeaderFooterView {
        
        if case .expired = self.subscriptionStatus {
            return OpenPurchaseOptionsTableViewFooterView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 66.0))
        } else {
            return OpenStoreTableViewFooterView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 66.0))
        }
    }

    var mainTableViewFooterView: UITableViewHeaderFooterView {
        if case .expired = self.subscriptionStatus {
            return SubscriptionExpiredTableViewFooterView.make(width: tableView.bounds.width)
        } else {
            return MainTableViewHeaderView.make(width: tableView.bounds.width)
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
