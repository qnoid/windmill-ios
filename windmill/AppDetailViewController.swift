//
//  AppDetailViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 01/05/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class AppDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    static func make(export: Export, storyboard: UIStoryboard = WindmillApp.Storyboard.subscriber()) -> AppDetailViewController? {
        let appDetailViewController = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? AppDetailViewController
        
        appDetailViewController?.export = export
        
        return appDetailViewController
    }

    enum Section: String, CodingKey {
        static var allValues: [Section] = [.identity, .deploymentInfo, .buildSettings, .distributionSummary, .information]
        
        case identity = "Identity"
        case deploymentInfo = "Deployment Info"
        case buildSettings = "Build Settings"
        case distributionSummary = "Distribution Summary"
        case information = "Information"
        
        func settings() -> [Setting] {
            switch self {
            case .identity:
                return [.displayName, .bundleIdentifier, .version, .build, .branch, .commit]
            case .deploymentInfo:
                return [.deploymentTarget]
            case .buildSettings:
                return [.configuration]
            case .distributionSummary:
                return [.certificateExpiryDate]
            case .information:
                return [.date]
            }
        }

    }
    
    enum Setting: String, CodingKey {
        case displayName = "Display Name"
        case bundleIdentifier = "Bundle Identifier"
        case version = "Version"
        case build = "Build"
        case branch = "Branch"
        case commit = "Commit"
        case configuration = "Configuration"
        case deploymentTarget = "Deployment Target"
        case certificateExpiryDate = "Certificate Expires"
        case date = "Updated at"
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.allowsSelection = false
            self.tableView.alwaysBounceVertical = false
            self.tableView.tableFooterView = UITableViewHeaderFooterView()
        }
    }
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE, d MMM y")
        
        return dateFormatter
    }()

    var sections = Section.allValues
    
    var export: Export? {
        didSet {
            if oldValue == nil {
                self.title = export?.title
                tableView?.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].settings().count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].stringValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell") else {
            return UITableViewCell()
        }
        
        let setting = self.sections[indexPath.section].settings()[indexPath.row]
        
        cell.textLabel?.text = setting.stringValue
        
        switch setting {
        case .displayName:
            cell.detailTextLabel?.text = export?.metadata.applicationProperties.bundleDisplayName
        case .bundleIdentifier:
            cell.detailTextLabel?.text = export?.bundle
        case .version:
            cell.detailTextLabel?.text = export?.version
        case .build:
            cell.detailTextLabel?.text = export?.metadata.applicationProperties.bundleVersion
        case .branch:
            cell.detailTextLabel?.text = export?.metadata.commit.branch
        case .commit:
            cell.detailTextLabel?.text = export?.metadata.commit.shortSha
        case .deploymentTarget:
            cell.detailTextLabel?.text = export?.metadata.deployment.target
        case .configuration:
            cell.detailTextLabel?.text = export?.metadata.configuration.name
        case .certificateExpiryDate:
            if let certificateExpiryDate = export?.metadata.distributionSummary.certificateExpiryDate {
                cell.detailTextLabel?.text = certificateExpiryDate.duration
            }
        case .date:
            if let modifiedAt = export?.modifiedAt {
                cell.detailTextLabel?.text = dateFormatter.string(from: modifiedAt)
            } else if let createdAt = export?.createdAt {
                cell.detailTextLabel?.text = dateFormatter.string(from: createdAt)
            }
        }
        
        return cell

    }

}

