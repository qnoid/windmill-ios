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
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        let setting = self.sections[indexPath.section].settings(for: self.subscriptionStatus)[indexPath.row]
        
        controller?.accessoryButtonTapped(setting: setting, cell: cell)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let setting = self.sections[indexPath.section].settings(for: self.subscriptionStatus)[indexPath.row]

        guard let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }

        switch setting {
        case .subscription:
            cell.accessoryType = .detailButton
        case .refreshSubscription, .restorePurchases:
            cell.accessoryView = UIActivityIndicatorView(style: .gray)
        default:
            break
        }

        return indexPath
    }
    
    func animateActivityIndicatorView(_ tableView: UITableView, at indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if let activityIndicatorView = cell?.accessoryView as? UIActivityIndicatorView {
            activityIndicatorView.startAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = self.sections[indexPath.section].settings(for: self.subscriptionStatus)[indexPath.row]
        
        animateActivityIndicatorView(tableView, at: indexPath)
        
        controller?.didSelect(setting: setting)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        if let activityIndicatorView = cell?.accessoryView as? UIActivityIndicatorView {
            activityIndicatorView.stopAnimating()
        }
    }
}
