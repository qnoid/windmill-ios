//
//  AccountTableViewDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 11/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class AccountTableViewDelegate: NSObject, UITableViewDelegate {
    
    weak var controller: AccountViewController?
    
    let settings: [AccountViewController.Setting]
    
    init(settings: [AccountViewController.Setting]) {
        self.settings = settings
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let setting = settings[indexPath.row]
        
        controller?.accessoryButtonTapped(setting: setting)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = settings[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath)
        
        switch setting {
            case .restorePurchases:
                cell?.accessoryView = UIActivityIndicatorView(style: .gray)
            default:
                break
        }
        
        controller?.didSelect(setting: setting)
    }
}
