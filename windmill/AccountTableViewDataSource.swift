//
//  AccountTableViewDataSource.swift
//  windmill
//
//  Created by Markos Charatzas on 11/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class AccountTableViewDataSource: NSObject, UITableViewDataSource {
 
    weak var controller: AccountViewController?

    var sections: [AccountViewController.Section] {
        return AccountViewController.Section.allValues
    }

    let settings: [AccountViewController.Setting]
    
    init(settings: [AccountViewController.Setting]) {
        self.settings = settings
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].stringValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableViewCell") else {
            return UITableViewCell()
        }
        
        let setting = settings[indexPath.row]
        
        controller?.cell(cell, for:setting)
        cell.textLabel?.text = setting.stringValue
        
        return cell
    }
}
