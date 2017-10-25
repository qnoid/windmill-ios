//
//  ViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 04/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit

import os

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet{
            
            self.tableView.register(WindmillTableViewCell.self, forCellReuseIdentifier: "WindmillTableViewCell")
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.dataSource = self.dataSource
            self.tableView.delegate = self.delegate
            self.tableView.alwaysBounceVertical = false
            
            let tableFooterView = InstallTableViewFooterView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 60.0))
            self.tableView.tableFooterView = tableFooterView
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
    
    override func applicationFinishedRestoringState() {
        self.updateTableViewHeaderView()
    }
    
    private func updateTableViewHeaderView() {
        let tableHeaderView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 40.0))
        tableHeaderView.textLabel?.font = UIFont.preferredFont(forTextStyle: .caption2)
        tableHeaderView.textLabel?.textAlignment = .center
        tableHeaderView.textLabel?.text = self.account
        
        self.tableView.tableHeaderView = tableHeaderView
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
        self.updateTableViewHeaderView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.reloadWindmills(account: self.account)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didTouchUpInsideClose(_ sender: UIBarButtonItem) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTouchUpInsideRefresh(_ sender: UIBarButtonItem) {
        self.reloadWindmills(account: self.account)
    }
}

