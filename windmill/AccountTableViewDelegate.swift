//
//  AccountTableViewDelegate.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 11/02/2019.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
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
