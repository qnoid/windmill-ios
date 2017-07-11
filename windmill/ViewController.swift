//
//  ViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 04/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet{
            
            self.tableView.register(WindmillTableViewCell.self, forCellReuseIdentifier: "WindmillTableViewCell")
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.dataSource = self.dataSource
            self.tableView.delegate = self.delegate
            self.tableView.tableFooterView = UIView()
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
    
    class func make(for account: String) -> ViewController {
        let viewController = UIStoryboard(name: "Main", bundle: Bundle(for: self)).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        viewController.account = account
        
        return viewController
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
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        
        guard let windmills = windmills else {
            let alertController = UIAlertController.Windmill.make(error: error)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        guard !windmills.isEmpty else {
            let tableFooterView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 40.0))
            tableFooterView.textLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
            tableFooterView.textLabel?.textAlignment = .center
            tableFooterView.textLabel?.text = "You haven't deployed any apps yet."
            
            self.tableView.tableFooterView = tableFooterView
            return
        }
        
        self.dataSource.windmills = windmills
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableHeaderView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 40.0))
        tableHeaderView.textLabel?.font = UIFont.preferredFont(forTextStyle: .caption2)
        tableHeaderView.textLabel?.textAlignment = .center
        tableHeaderView.textLabel?.text = self.account
        
        self.tableView.tableHeaderView = tableHeaderView
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

