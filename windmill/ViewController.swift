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
            
            self.tableView.registerNib(UINib(nibName: "WindmillTableViewCell", bundle:nil), forCellReuseIdentifier: "WindmillTableViewCell")
            self.tableView.dataSource = self.dataSource
            
            self.tableView.tableFooterView = UIView()
        }
    }
    
    lazy var dataSource = {
        return WindmillTableViewDataSource()
    }()
    
    let accountResource = AccountResource()
    
    private func reloadWindmills(account: String = "14810686-4690-4900-ADA5-8B0B7338AA39") {
        self.accountResource.URLSessionTaskWindmills(forAccount: account) { windmills, error in
            
            guard let windmills = windmills else {
                debugPrint(error)
                return
            }
            
            self.dataSource.windmills = windmills
            self.tableView.reloadData()
            }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadWindmills()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didTouchUpInsideRefresh(sender: UIButton) {
        self.reloadWindmills()
    }
}

