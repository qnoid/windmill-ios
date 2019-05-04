//
//  AccountTableViewDataSource.swift
//  windmill
//
//  Created by Markos Charatzas on 11/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

extension Array where Element == AccountViewController.Section {
    
    typealias Section = AccountViewController.Section
    
    func section(for section: Section) -> Int? {
        guard let index = self.firstIndex(of: section) else {
            return nil
        }
        
        return self.distance(from: startIndex, to: index)
    }
}

extension Array where Element == AccountViewController.Setting {
    
    typealias Setting = AccountViewController.Setting
    
    func row(for setting: Setting) -> Int? {
        guard let index = self.firstIndex(of: setting) else {
            return nil
        }
        
        return self.distance(from: startIndex, to: index)
    }
}

class AccountTableViewDataSource: NSObject, UITableViewDataSource {
 
    typealias Section = AccountViewController.Section
    typealias Setting = AccountViewController.Setting

    var subscriptionStatus = SubscriptionStatus.default {
        didSet {
            self.sections = Section.sections(for: subscriptionStatus)
        }
    }
    var sections = [Section]()
    
    func indexPath(for section: Section, setting: Setting) -> IndexPath? {
        
        guard let row = section.settings(for: self.subscriptionStatus).row(for: setting) else {
            return nil
        }
        
        
        guard let section = self.sections.section(for: section) else {
            return nil
        }
        
        return IndexPath(row: row, section: section)
    }

    func indexPath(section: Section, setting: Setting) -> IndexPath? {
        return self.indexPath(for: section, setting: setting)
    }
    
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

        switch setting {
        case .subscription:
            cell.accessoryType = .detailButton
        case .refreshSubscription, .restorePurchases:
            cell.accessoryView = UIActivityIndicatorView(style: .gray)
        default:
            break
        }

        cell.textLabel?.text = setting.stringValue
        
        return cell
    }
}
