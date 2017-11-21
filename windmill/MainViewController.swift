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
            self.tableView.rowHeight = UITableViewAutomaticDimension
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
    
    let accountResource = AccountResource()
    
    var account: String = ""
    
    class func make(for account: String) -> MainViewController {
        let viewController = Storyboards.main().instantiateViewController(withIdentifier: String(describing: self)) as! MainViewController
        viewController.account = account
        
        return viewController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    }

    override func decodeRestorableState(with coder: NSCoder) {
        guard let account = try? ApplicationStorage.default.read(key: "account") else {
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
        self.tableView.tableHeaderView = self.headerFor(tableView: self.tableView, settings: settings)
    }
    
    private func headerFor(tableView: UITableView, settings: UNNotificationSettings) -> UITableViewHeaderFooterView {
    
        switch settings.authorizationStatus {
            
        case .notDetermined:
            let tableHeaderView = NotificationsNotDeterminedTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 82.0))
            tableHeaderView.delegate = self
            tableHeaderView.accountLabel.text = self.account
            
            return tableHeaderView
        case .denied:
            let tableHeaderView = NotificationsDeniedTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 82.0))
            tableHeaderView.delegate = self
            tableHeaderView.accountLabel.text = self.account
            
            return tableHeaderView
        case .authorized:
            let tableHeaderView = NotificationsAuthorizedTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 82.0))
            tableHeaderView.accountLabel.text = self.account
            
            return tableHeaderView
        }
    }
    
    private func reloadWindmills(account: String) {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        
        self.accountResource.requestWindmills(forAccount: account) { [weak self] windmills, error in
            self?.didFinishURLSessionTaskWindmills(activityIndicatorView: activityIndicatorView, windmills: windmills, error: error)
            }.resume()
    }
    
    func didFinishURLSessionTaskWindmills(activityIndicatorView: UIActivityIndicatorView, windmills: [Windmill]?, error: Error?) {
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.stopAnimating()
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        
        guard let windmills = windmills else {
            let alertController = UIAlertController.Windmill.make(error: error)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        guard !windmills.isEmpty else {
            return
        }
        
        self.dataSource.windmills = windmills
        self.tableView.reloadData()
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
        
        self.reloadWindmills(account: self.account)
    }
    
    @IBAction func didTouchUpInsideClose(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTouchUpInsideRefresh(_ sender: UIBarButtonItem) {
        self.reloadWindmills(account: self.account)
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
            
            let tableViewHeaderView = NotificationsDeniedTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 82.0))
            tableViewHeaderView.accountLabel.text = self.account
            tableViewHeaderView.delegate = self
            
            self.tableView.tableHeaderView = tableViewHeaderView
            return
        }
        
        let tableHeaderView = NotificationsAuthorizedTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 82.0))
        tableHeaderView.accountLabel.text = self.account
        self.tableView.tableHeaderView = tableHeaderView
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func didTouchUpInsideOpenSettingsButton(_ headerView: NotificationsDeniedTableViewHeaderView, button: UIButton) {
        guard let applicationOpenSettingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(applicationOpenSettingsURL, options: [:])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert])
    }

}

