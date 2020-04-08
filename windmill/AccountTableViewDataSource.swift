//
//  AccountTableViewDataSource.swift
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

extension Array where Element : Equatable {
    
    func section(for section: Element) -> Int? {
        guard let index = self.firstIndex(of: section) else {
            return nil
        }
        
        return self.distance(from: startIndex, to: index)
    }
}

extension Array where Element : Equatable {
    
    func row(for row: Element) -> Int? {
        guard let index = self.firstIndex(of: row) else {
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
