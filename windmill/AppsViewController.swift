//
//  ViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 04/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit
import UserNotifications
import os

/**
    The `AppsViewController` guarantees that a user was once a subscriber.
 */
class AppsViewController: UIViewController, NotifyTableViewHeaderViewDelegate, NotificationsDisabledTableViewHeaderViewDelegate, ExportTableViewCellDelegate {
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            self.tableView.tableHeaderView = NotificationsNotDeterminedTableViewHeaderView.make(width: tableView.bounds.width)
            self.tableView.register(ExportTableViewCell.self, forCellReuseIdentifier: "ExportTableViewCell")
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.dataSource = self.dataSource
            self.tableView.delegate = self.delegate
            self.tableView.alwaysBounceVertical = false
            self.tableView.tableFooterView = InstallTableViewFooterView.make(width: self.tableView.bounds.width)
        }
    }
    
    lazy var dataSource: ExportTableViewDataSource = { [weak self] in
        let dataSource = ExportTableViewDataSource()
        dataSource.controller = self
        return dataSource
    }()
    
    lazy var delegate: ExportTableViewDelegate = { [weak self] in
        let delegate = ExportTableViewDelegate()
        delegate.controller = self
        return delegate
    }()
    
    @IBOutlet var rightBarButtonItem: UIBarButtonItem!
    
    weak var paymentQueue: PaymentQueue? = PaymentQueue.default

    let subscriptionManager = SubscriptionManager()
    
    var subscriptionStatus: SubscriptionStatus? {
        didSet {
            if oldValue == nil, case .active(let account, let authorizationToken)? = subscriptionStatus {
                self.refreshExports(account: account, authorizationToken: authorizationToken)
            }
        }
    }
    
    class func make(storyboard: UIStoryboard = WindmillApp.Storyboard.subscriber()) -> AppsViewController? {
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? AppsViewController
        
        return viewController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(contentAvailable(notification:)), name: WindmillApp.ContentAvailable, object: WindmillApp.default)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestored(notification:)), name: SubscriptionManager.SubscriptionRestored, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(contentAvailable(notification:)), name: WindmillApp.ContentAvailable, object: WindmillApp.default)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionRestored(notification:)), name: SubscriptionManager.SubscriptionRestored, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)
    }
    
    @objc func didBecomeActive(notification: NSNotification) {

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.didGetNotificationSettings(settings: settings)
            }
        }
    }
    
    @objc func contentAvailable(notification: NSNotification) {
        guard let exports = notification.userInfo?["exports"] as? [Export] else {
            return
        }
        
        self.delegate.exports = exports
        self.dataSource.exports = exports
        self.tableView?.reloadData()
    }
    
    @objc func subscriptionActive(notification: NSNotification) {
        self.subscriptionStatus = SubscriptionStatus.default
    }

    @objc func subscriptionRestored(notification: NSNotification) {
        self.refreshExports()
    }

    private func didGetNotificationSettings(settings: UNNotificationSettings) {
        if let tableView = self.tableView {
            tableView.tableHeaderView = self.headerFor(tableView: tableView, settings: settings)
        }
    }
    
    private func headerFor(tableView: UITableView, settings: UNNotificationSettings) -> UITableViewHeaderFooterView {
    
        switch settings.authorizationStatus {
            
        case .notDetermined:
            let tableHeaderView = NotificationsNotDeterminedTableViewHeaderView.make(width: tableView.bounds.width)
            tableHeaderView.delegate = self
            
            return tableHeaderView
        case .denied:
            let tableHeaderView = NotificationsDeniedTableViewHeaderView.make(width: tableView.bounds.width)
            tableHeaderView.delegate = self
            
            return tableHeaderView
        case .authorized, .provisional:
            let tableHeaderView = NotificationsAuthorizedTableViewHeaderView.make(width: tableView.bounds.width)
            
            return tableHeaderView
        @unknown default:
            let tableHeaderView = NotificationsNotDeterminedTableViewHeaderView.make(width: tableView.bounds.width)
            tableHeaderView.delegate = self
            
            return tableHeaderView
        }
    }
    
    private func refreshExports(account: Account, authorizationToken token: SubscriptionAuthorizationToken) {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        activityIndicatorView.startAnimating()

        self.subscriptionManager.listExports(forAccount: account, token: token) { [weak self] exports, error in
            self?.didFinishURLSessionTaskExports(activityIndicatorView: activityIndicatorView, exports: exports, error: error)
            }
    }
    
    func didFinishURLSessionTaskExports(activityIndicatorView: UIActivityIndicatorView, exports: [Export]?, error: Error?) {
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.stopAnimating()
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        
        switch error {
        case let error as SubscriptionError where error.isExpired:
            self.tableView.tableFooterView = SubscriptionExpiredTableViewFooterView.make(width: self.tableView.bounds.width)
        case let error as SubscriptionError:
            let alertController = UIAlertController.Windmill.makeSubscription(error: error)
            present(alertController, animated: true, completion: nil)
        case .some(let error):
            let alertController = UIAlertController.Windmill.make(title: "Error", error: error)
            present(alertController, animated: true, completion: nil)
        default:
            break
        }
        
        guard let exports = exports else {
            return
        }
        
        self.delegate.exports = exports
        self.dataSource.exports = exports
        self.tableView?.tableFooterView = InstallTableViewFooterView.make(width: self.tableView.bounds.width)
        self.tableView?.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if case .active(let account, let authorizationToken) = SubscriptionStatus.default {
            self.refreshExports(account: account, authorizationToken: authorizationToken)
        }

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.didGetNotificationSettings(settings: settings)
            }
        }
    }
    
    @IBAction func didTouchUpInsideRefresh(_ sender: UIBarButtonItem) {
        self.refreshExports()
    }
    
    func refreshExports(subscriptionStatus: SubscriptionStatus = SubscriptionStatus.default) {
        switch subscriptionStatus {
        case .active(let account, let authorizationToken):
            self.refreshExports(account: account, authorizationToken: authorizationToken)
        case .expired(let account, _):
            if let token = try? ApplicationStorage.default.read(key: .subscriptionAuthorizationToken) {
                self.refreshExports(account: account, authorizationToken: SubscriptionAuthorizationToken(value: token))
            }
        default:
            return
        }
    }
    
    func didTouchUpInsideAuthorizeButton(_ headerView: NotificationsNotDeterminedTableViewHeaderView, button: UIButton) {
        
        let userNotificationCenter = UNUserNotificationCenter.current()
        
        userNotificationCenter.requestAuthorization(options: [.alert]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.didCompleteRequestAuthorization(granted: granted, error: error)
            }
        }
    }
    
    func didCompleteRequestAuthorization(granted: Bool, error: Error?) {
        
        guard granted else {
            if let error = error {
                os_log("%{public}@", log: .default, type: .error, error.localizedDescription)
            }
            
            let tableViewHeaderView = NotificationsDeniedTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 66.0))
            tableViewHeaderView.delegate = self
            
            self.tableView.tableHeaderView = tableViewHeaderView
            return
        }
        
        let tableHeaderView = NotificationsAuthorizedTableViewHeaderView.make(width: self.tableView.bounds.width)
        self.tableView.tableHeaderView = tableHeaderView
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func didTouchUpInsideOpenSettingsButton(_ headerView: NotificationsDeniedTableViewHeaderView, button: UIButton) {
        guard let applicationOpenSettingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(applicationOpenSettingsURL, options: [:])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert])
    }

    func tableViewCell(_ cell: ExportTableViewCell, installButtonTapped: InstallButton, forExport export: Export) {
        
        if case .error(let error) = export.status {
            let alertController = UIAlertController.Windmill.makeExport(error: error)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func detailDisclosureFor(export: Export) {
        
        guard let appDetailNavigationController = AppDetailNavigationController.make(export: export) else {
            return
        }
        
        self.present(appDetailNavigationController, animated: true)
    }
    
    @IBAction @objc func unwindToAppsViewController(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction @objc func unwindToAppsViewControllerReload(_ segue: UIStoryboardSegue) {
        self.refreshExports()
    }
}

