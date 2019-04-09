//
//  AccountTableViewDataSource.swift
//  windmill
//
//  Created by Markos Charatzas on 11/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class AccountTableViewDataSource: NSObject, UITableViewDataSource {
 
    typealias Section = AccountViewController.Section
    typealias Setting = AccountViewController.Setting
    
    @IBOutlet weak var controller: AccountViewController?

    var subscriptionStatus = SubscriptionStatus.default {
        didSet {
            self.sections = Section.sections(for: subscriptionStatus)
        }
    }
    var sections = [Section]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].settings(for: self.subscriptionStatus).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].stringValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell") else {
            return UITableViewCell()
        }
        cell.accessoryView = nil

        let setting = self.sections[indexPath.section].settings(for: self.subscriptionStatus)[indexPath.row]

        controller?.cell(cell, for:setting)
        cell.textLabel?.text = setting.stringValue
        
        return cell
    }
}
