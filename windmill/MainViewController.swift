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

class MainViewController: UIViewController, NotifyTableViewHeaderViewDelegate, NotificationsDisabledTableViewHeaderViewDelegate {

    @IBOutlet weak var tableView: UITableView! {
        didSet{
            
            self.tableView.register(WindmillTableViewCell.self, forCellReuseIdentifier: "WindmillTableViewCell")
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.dataSource = self.dataSource
            self.tableView.delegate = self.delegate
            self.tableView.alwaysBounceVertical = false
            self.tableView.tableFooterView = InstallTableViewFooterView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 60.0))
        }
    }
    
    lazy var dataSource = {
        return WindmillTableViewDataSource()
    }()
    
    lazy var delegate = {
        return WindmillTableViewDelegate()
    }()
    
    @IBOutlet var rightBarButtonItem: UIBarButtonItem!
    
    weak var paymentQueue: PaymentQueue? = PaymentQueue.default
    
    let accountResource = AccountResource()
    
    var account: String? {
        didSet {
            if oldValue == nil, let account = account {
                self.reloadWindmills(account: account)
            }
        }
    }
    
    class func make(for account: String) -> MainViewController {
        let viewController = Storyboards.main().instantiateViewController(withIdentifier: String(describing: self)) as! MainViewController
        viewController.account = account
        
        return viewController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(isSubscriber(notification:)), name: Account.isSubscriber, object: paymentQueue)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(isSubscriber(notification:)), name: Account.isSubscriber, object: paymentQueue)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    }

    override func decodeRestorableState(with coder: NSCoder) {
        guard let account = try? ApplicationStorage.default.read(key: .account) else {
            return
        }
        
        self.account = account
        super.decodeRestorableState(with: coder)
    }
    
    @objc func didBecomeActive(notification: NSNotification) {

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.didGetNotificationSettings(settings: settings)
            }
        }
    }
    
    private func didGetNotificationSettings(settings: UNNotificationSettings) {
        if let tableView = self.tableView {
            tableView.tableHeaderView = self.headerFor(tableView: tableView, settings: settings)
        }
    }
    
    @objc func isSubscriber(notification: NSNotification) {
        self.dismiss(animated: true, completion: nil)
        self.account = try? ApplicationStorage.default.read(key: .account)
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
            self.tableView.reloadData()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.didGetNotificationSettings(settings: settings)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func didTouchUpInsideStore(_ sender: UIBarButtonItem) {
        
        guard let purchaseViewController = Storyboards.purchase().instantiateInitialViewController() else {
            return
        }
        
        self.present(purchaseViewController, animated: true)
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

