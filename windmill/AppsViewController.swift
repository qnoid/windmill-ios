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
class AppsViewController: UIViewController, NotifyTableViewHeaderViewDelegate, NotificationsDisabledTableViewHeaderViewDelegate {

    @IBOutlet weak var tableView: UITableView! {
        didSet{
            self.tableView.tableHeaderView = NotificationsNotDeterminedTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 66.0))
            self.tableView.register(ExportTableViewCell.self, forCellReuseIdentifier: "ExportTableViewCell")
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.dataSource = self.dataSource
            self.tableView.delegate = self.delegate
            self.tableView.alwaysBounceVertical = false
            self.tableView.tableFooterView = InstallTableViewFooterView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 60.0))
        }
    }
    
    lazy var dataSource = {
        return ExportTableViewDataSource()
    }()
    
    lazy var delegate = {
        return ExportTableViewDelegate()
    }()
    
    @IBOutlet var rightBarButtonItem: UIBarButtonItem!
    
    weak var paymentQueue: PaymentQueue? = PaymentQueue.default

    let accountResource = AccountResource()
    
    var account: String? = try? ApplicationStorage.default.read(key: .account) {
        didSet {
            if oldValue == nil, let account = account {
                self.reloadWindmills(account: account)
            }
        }
    }
    
    class func make(for account: String? = nil, storyboard: UIStoryboard = WindmillApp.Storyboard.subscriber()) -> AppsViewController? {
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? AppsViewController
        viewController?.account = account
        
        return viewController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActive(notification:)), name: SubscriptionManager.SubscriptionActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        self.account = try? ApplicationStorage.default.read(key: .account)
        
        super.decodeRestorableState(with: coder)
    }
    
    @objc func didBecomeActive(notification: NSNotification) {

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.didGetNotificationSettings(settings: settings)
            }
        }
    }
    
    @objc func subscriptionActive(notification: NSNotification) {
        self.account = try? ApplicationStorage.default.read(key: .account)
    }
    
    private func didGetNotificationSettings(settings: UNNotificationSettings) {
        if let tableView = self.tableView {
            tableView.tableHeaderView = self.headerFor(tableView: tableView, settings: settings)
        }
    }
    
    private func headerFor(tableView: UITableView, settings: UNNotificationSettings) -> UITableViewHeaderFooterView {
    
        switch settings.authorizationStatus {
            
        case .notDetermined:
            let tableHeaderView = NotificationsNotDeterminedTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 66.0))
            tableHeaderView.delegate = self
            
            return tableHeaderView
        case .denied:
            let tableHeaderView = NotificationsDeniedTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 66.0))
            tableHeaderView.delegate = self
            
            return tableHeaderView
        case .authorized, .provisional:
            let tableHeaderView = NotificationsAuthorizedTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 66.0))
            
            return tableHeaderView
        }
    }
    
    private func reloadWindmills(account: String) {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        activityIndicatorView.startAnimating()

        self.accountResource.requestExports(forAccount: account) { [weak self] exports, error in
            self?.didFinishURLSessionTaskExports(activityIndicatorView: activityIndicatorView, exports: exports, error: error)
            }.resume()
    }
    
    func didFinishURLSessionTaskExports(activityIndicatorView: UIActivityIndicatorView, exports: [Export]?, error: Error?) {
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.stopAnimating()
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        
        switch error {
        case .some(let error):
            let alertController = UIAlertController.Windmill.make(title: "Error", error: error)
            self.present(alertController, animated: true, completion: nil)
        default:
            guard let exports = exports else {
                return
            }
        
            guard !exports.isEmpty else {
                return
            }
        
            self.dataSource.exports = exports
            self.tableView?.reloadData()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let account = self.account {
            reloadWindmills(account: account)
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.didGetNotificationSettings(settings: settings)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func didTouchUpInsideRefresh(_ sender: UIBarButtonItem) {
        guard let account = try? ApplicationStorage.default.read(key: .account) else {
            return
        }
        
        self.reloadWindmills(account: account)
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
        
        let tableHeaderView = NotificationsAuthorizedTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 66.0))
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

}

