//
//  AccountTableViewDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 11/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class AccountTableViewDelegate: NSObject, UITableViewDelegate {

    typealias Section = AccountViewController.Section
    typealias Setting = AccountViewController.Setting

    @IBOutlet weak var controller: AccountViewController?
    
    var subscriptionStatus = SubscriptionStatus.default {
        didSet {
            self.sections = Section.sections(for: subscriptionStatus)
        }
    }
    var sections = [Section]()

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let setting = self.sections[indexPath.section].settings(for: self.subscriptionStatus)[indexPath.row]
        
        controller?.accessoryButtonTapped(setting: setting)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = self.sections[indexPath.section].settings(for: self.subscriptionStatus)[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath)

        if let activityIndicatorView = cell?.accessoryView as? UIActivityIndicatorView {
            activityIndicatorView.startAnimating()
        }
        
        controller?.didSelect(setting: setting)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        if let activityIndicatorView = cell?.accessoryView as? UIActivityIndicatorView {
            activityIndicatorView.stopAnimating()
        }
    }
}
