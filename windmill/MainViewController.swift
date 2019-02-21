//
//  MainViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 12/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var mainTableViewHeaderView: UITableViewHeaderFooterView {
        
        if case .active = self.subscriptionStatus {
            return SubcriberTableViewFooterView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44.0))
        } else {
            return MainTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44.0))
        }
    }

    var mainTableViewFooterView: UITableViewHeaderFooterView {
        if case .active = self.subscriptionStatus {
            return UITableViewHeaderFooterView()
        } else {
            return OpenStoreTableViewFooterView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 66.0))
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet{
            self.tableView.tableHeaderView = self.mainTableViewHeaderView
            self.tableView.register(MockExportTableViewCell.self, forCellReuseIdentifier: "MockExportTableViewCell")
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.allowsSelection = false
            self.tableView.alwaysBounceVertical = false
            self.tableView.tableFooterView = self.mainTableViewFooterView
        }
    }
    
    var subscriptionStatus = SubscriptionStatus.shared {
        didSet {
            self.tableView?.tableHeaderView = self.mainTableViewHeaderView
            self.tableView?.tableFooterView = self.mainTableViewFooterView
            self.tableView?.reloadData()
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
    }
    
    @objc func subscriptionActive(notification: NSNotification) {
        self.subscriptionStatus = SubscriptionStatus.shared
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.subscriptionStatus.isActive ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subscriptionStatus.isActive ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MockExportTableViewCell") as? MockExportTableViewCell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 107
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 107
    }
}
