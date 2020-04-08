//
//  WindmillHelpTableViewController.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 08/05/2019.
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

class HelpTableViewController: UITableViewController {
    
    enum Section: String, CodingKey {
        static var allValues: [Section] = [.welcome, .gettingStarted, .basics, .installation, .security, .subscription]
        
        case welcome = "Welcome"
        case gettingStarted = "Getting Started"
        case basics = "Windmill Basics"
        case installation = "Installation"
        case security = "Windmill Security"
        case subscription = "Subscription"
        
        func children() -> [Child] {
            switch self {
            case .welcome:
                return [.welcome]
            case .gettingStarted:
                return [.whereToStart, .registerADevice, .distribution]
            case .basics:
                return [.installation, .details, .delete]
            case .installation:
                return [.distributionCertificatedExpired, .unsupported, .deviceNotRegistered, .elapsed]
            case .security:
                return [.access, .registeredDevice, .accessExpires, .revokeBuild]
            case .subscription:
                return [.restore, .refresh]
            }
        }
        
    }
    
    enum Child: String, CodingKey {
        case welcome = "Welcome"
        case whereToStart = "Where to start"
        case registerADevice = "Register a device"
        case distribution = "Distributing your application"
        case installation = "Install your application"
        case details = "Details of your application"
        case delete = "Delete your application"
        case distributionCertificatedExpired = "Distribution Certificated Expired"
        case unsupported = "Unsupported iOS"
        case elapsed = "Access Elapsed"
        case deviceNotRegistered = "Device not registered"
        case access = "Access to your applications"
        case accessExpires = "Time-limited access to install a build"
        case registeredDevice = "Registered devices only"
        case revokeBuild = "Revoke a build"
        case restore = "Restore Purchases"
        case refresh = "Refresh Subscription"
        
        var message: NSAttributedString {
            let attributes: [NSAttributedString.Key : Any] = [.font: UIFont.preferredFont(forTextStyle: .body)]
            
            switch self {
            case .welcome:
                return NSAttributedString()
            case .whereToStart:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.getting_started.where_to_start.message", comment: ""),
                                          attributes:attributes)
            case .registerADevice:
                let string = NSLocalizedString("io.windmill.windmill.help.getting_started.register_a_device.message", comment: "")
                let message = NSMutableAttributedString(string: string as String, attributes:attributes)
                
                if let url = URL(string: "https://help.apple.com/developer-account/#/dev40df0d9fa") {
                    message.addAttribute(.link, value: url, range: (string as NSString).range(of: "register a device"))
                }
                
                if let url = URL(string: "https://help.apple.com/xcode/mac/10.0/#/dev93ef696c6") {
                    message.addAttribute(.link, value: url, range: (string as NSString).range(of: "device identifier"))
                }
                
                return message
            case .distribution:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.getting_started.distribution.message", comment: ""),
                                          attributes:attributes)
            case .installation:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.basics.installation.message", comment: ""),
                                          attributes:attributes)
            case .details:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.basics.details.message", comment: ""),
                                          attributes:attributes)
            case .delete:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.basics.delete.message", comment: ""),
                                          attributes:attributes)
            case .distributionCertificatedExpired:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.installation.errors.certificate_expired.message", comment: ""),
                                          attributes:attributes)
            case .unsupported:
                let string = NSLocalizedString("io.windmill.windmill.help.installation.errors.unsupported_ios.message", comment: "")
                let message = NSMutableAttributedString(string: string, attributes:attributes)
                
                if let url = URL(string: "https://help.apple.com/xcode/mac/10.0/#/deve69552ee5") {
                    message.addAttribute(.link, value: url, range: (string as NSString).range(of: "deployment target"))
                }
                
                return message
            case .elapsed:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.installation.errors.elapsed.message", comment: ""),
                                          attributes:attributes)
            case .deviceNotRegistered:
                let string = NSLocalizedString("io.windmill.windmill.help.installation.errors.unregistered_device.message", comment: "")
                let message = NSMutableAttributedString(string: string, attributes:attributes)
                
                if let url = URL(string: "https://help.apple.com/developer-account/#/dev40df0d9fa") {
                    message.addAttribute(.link, value: url, range: (string as NSString).range(of: "device must be registered"))
                }
                
                if let url = URL(string: "https://help.apple.com/xcode/mac/10.0/#/dev93ef696c6") {
                    message.addAttribute(.link, value: url, range: (string as NSString).range(of: "device identifier"))
                }
                
                return message
            case .access:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.security.access.message", comment: ""),
                                          attributes:attributes)
            case .registeredDevice:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.security.registered_devices.message", comment: ""),
                                          attributes:attributes)
            case .accessExpires:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.security.expiry.message", comment: ""),
                                          attributes:attributes)
            case .revokeBuild:
                let string = NSLocalizedString("io.windmill.windmill.help.security.revoke_build.message", comment: "")
                let message = NSMutableAttributedString(string: string,
                                                        attributes:attributes)
                
                if let url = URL(string: "https://help.apple.com/developer-account/#/dev7d381a7ff") {
                    message.addAttribute(.link, value: url, range: (string as NSString).range(of: "revoke the distribution certificate"))
                }
                
                return message
            case .restore:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.subscription.restore.message", comment: ""),
                                          attributes:attributes)
            case .refresh:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.subscription.refresh.message", comment: ""),
                                          attributes:attributes)
            }
        }
    }
    
    var sections = Section.allValues
    
    var section: (section: Section, child: Child) {
        
        guard let indexPathForSelectedRow = self.tableView.indexPathForSelectedRow else {
            preconditionFailure()
        }
        
        let section = self.sections[indexPathForSelectedRow.section]
        let child = section.children()[indexPathForSelectedRow.row]
        
        return (section, child)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.alwaysBounceVertical = false
        self.tableView.tableFooterView = UITableViewHeaderFooterView()
    }
    
    func indexPath(for section: Section, row: Child) -> IndexPath? {
        
        guard let row = section.children().row(for: row) else {
            return nil
        }
        
        
        guard let section = self.sections.section(for: section) else {
            return nil
        }
        
        return IndexPath(row: row, section: section)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].children().count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = sections[section]
        
        return section == .welcome ? nil : section.stringValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HelpTableViewCell") else {
            return UITableViewCell()
        }
        
        let child = self.sections[indexPath.section].children()[indexPath.row]
        cell.textLabel?.text = child.stringValue
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let child = self.sections[indexPath.section].children()[indexPath.row]
        
        switch child {
        case .welcome:
            self.navigationController?.popViewController(animated: true)
        default:
            return
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return self.section.section != .welcome
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let helpSectionViewController = segue.destination as? HelpSectionViewController  {
            helpSectionViewController.section = self.section
        }
    }
}
