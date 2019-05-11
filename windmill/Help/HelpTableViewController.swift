//
//  WindmillHelpTableViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 08/05/2019.
//  Copyright © 2019 Windmill. All rights reserved.
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
                return [.distributionCertificatedExpired, .unsupported, .deviceNotRegistered]
            case .security:
                return [.access, .registeredDevice, .expiredBuilds, .revokeBuild]
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
        case deviceNotRegistered = "Device not registered"
        case access = "Access to your applications"
        case expiredBuilds = "Builds do expire"
        case registeredDevice = "Registered devices only"
        case revokeBuild = "Revoke a build"
        case restore = "Restore Purchases"
        case refresh = "Refresh Subscription"
        
        var message: NSAttributedString {
            switch self {
            case .whereToStart:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.getting_started.where_to_start.message", comment: ""), attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
            case .registerADevice:
                let string = NSLocalizedString("io.windmill.windmill.help.getting_started.register_a_device.message", comment: "")
                let message = NSMutableAttributedString(string: string as String, attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
                
                if let url = URL(string: "https://help.apple.com/developer-account/#/dev40df0d9fa") {
                    message.addAttribute(.link, value: url, range: (string as NSString).range(of: "register a device"))
                }
                
                if let url = URL(string: "https://help.apple.com/xcode/mac/10.0/#/dev93ef696c6") {
                    message.addAttribute(.link, value: url, range: (string as NSString).range(of: "device identifier"))
                }
                
                return message
            case .distribution:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.getting_started.distribution.message", comment: ""), attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
            case .installation:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.basics.installation.message", comment: ""), attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
            case .details:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.basics.details.message", comment: ""), attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
            case .delete:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.basics.delete.message", comment: ""), attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
            case .distributionCertificatedExpired:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.installation.errors.certificate_expired.message", comment: ""), attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
            case .unsupported:
                let string = NSLocalizedString("io.windmill.windmill.help.installation.errors.unsupported_ios.message", comment: "")
                let message = NSMutableAttributedString(string: string, attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
                
                if let url = URL(string: "https://help.apple.com/xcode/mac/10.0/#/deve69552ee5") {
                    message.addAttribute(.link, value: url, range: (string as NSString).range(of: "deployment target"))
                }
                
                return message
            case .deviceNotRegistered:
                let string = NSLocalizedString("io.windmill.windmill.help.installation.errors.unregistered_device.message", comment: "")
                let message = NSMutableAttributedString(string: string, attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
                
                if let url = URL(string: "https://help.apple.com/developer-account/#/dev40df0d9fa") {
                    message.addAttribute(.link, value: url, range: (string as NSString).range(of: "device must be registered"))
                }
                
                if let url = URL(string: "https://help.apple.com/xcode/mac/10.0/#/dev93ef696c6") {
                    message.addAttribute(.link, value: url, range: (string as NSString).range(of: "device identifier"))
                }
                
                return message
            case .access:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.security.access.message", comment: ""), attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
            case .registeredDevice:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.security.registered_devices.message", comment: ""), attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
            case .expiredBuilds:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.security.expiry.message", comment: ""), attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
            case .revokeBuild:
                let string = NSLocalizedString("io.windmill.windmill.help.security.revoke_build.message", comment: "")
                let message = NSMutableAttributedString(string: string, attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
                
                if let url = URL(string: "https://help.apple.com/developer-account/#/dev7d381a7ff") {
                    message.addAttribute(.link, value: url, range: (string as NSString).range(of: "revoke the distribution certificate"))
                }
                
                return message
            case .restore:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.subscription.restore.message", comment: ""), attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
            case .refresh:
                return NSAttributedString(string: NSLocalizedString("io.windmill.windmill.help.subscription.refresh.message", comment: ""), attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
            default:
                return NSAttributedString()
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
