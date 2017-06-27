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
            
            self.tableView.register(UINib(nibName: "WindmillTableViewCell", bundle:nil), forCellReuseIdentifier: "WindmillTableViewCell")
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
    
    let accountResource = AccountResource()
    
    var account: String = ""
    
    class func make(for account: String) -> ViewController {
        let viewController = UIStoryboard(name: "Main", bundle: Bundle(for: self)).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        viewController.account = account
        
        return viewController
    }
    
    fileprivate func reloadWindmills(account: String) {
        self.accountResource.URLSessionTaskWindmills(forAccount: account) { windmills, error in
            
            guard let windmills = windmills else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            guard !windmills.isEmpty else {
                let tableFooterView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 40.0))
                tableFooterView.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
                tableFooterView.textLabel?.textAlignment = .center
                tableFooterView.textLabel?.text = "You haven't deployed any apps yet."
                
                self.tableView.tableFooterView = tableFooterView
                return
            }
            
            self.dataSource.windmills = windmills
            self.tableView.reloadData()
            }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableHeaderView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 40.0))
        tableHeaderView.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
        tableHeaderView.textLabel?.textAlignment = .center
        tableHeaderView.textLabel?.text = self.account
        
        self.tableView.tableHeaderView = tableHeaderView
        
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

