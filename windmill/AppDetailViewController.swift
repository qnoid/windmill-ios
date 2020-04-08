//
//  AppDetailViewController.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 01/05/2019.
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
import os

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
        
        func details() -> [Detail] {
            switch self {
            case .identity:
                return [.displayName, .bundleIdentifier, .version, .build, .branch, .commit, .date]
            case .deploymentInfo:
                return [.deploymentTarget]
            case .buildSettings:
                return [.configuration]
            case .distributionSummary:
                return [.certificateExpiryDate]
            case .information:
                return [.distributed, .elapses]
            }
        }

    }
    
    enum Detail: String, CodingKey {
        case displayName = "Display Name"
        case bundleIdentifier = "Bundle Identifier"
        case version = "Version"
        case build = "Build"
        case branch = "Branch"
        case commit = "Commit"
        case date = "Date"
        case configuration = "Configuration"
        case deploymentTarget = "Deployment Target"
        case certificateExpiryDate = "Certificate Expires"
        case distributed = "Distributed at"
        case elapses = "Elapses"
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
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE, d MMM y HH:mm")
        
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
    
    let exportResource = ExportResource()
    
    func delete(export: Export, claim: SubscriptionClaim) {
        
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.color = UIColor.red
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        activityIndicatorView.startAnimating()

        self.exportResource.requestDelete(export: export, claim: claim, completion: { [weak self] (error) in
            self?.didFinishRequestDeleteExport(activityIndicatorView: activityIndicatorView, error: error)
        }).resume()
    }
    
    func didFinishRequestDeleteExport(activityIndicatorView: UIActivityIndicatorView, error: Error?) {
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.stopAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteDistribution(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        
        if let error = error {
            let alertController = UIAlertController.Windmill.make(title: "Delete Build Failed", error: error)
            self.present(alertController, animated: true)
        } else {
            self.performSegue(withIdentifier: "DeleteExportUnwind", sender: self)
        }
    }
    
    @IBAction func deleteDistribution(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteDistribution = UIAlertAction(title: "Delete Build", style: .destructive) { alert in
            
            guard let export = self.export, let claim = try? ApplicationStorage.default.read(key: .subscriptionClaim) else {
                return
            }
            
            self.delete(export: export, claim: SubscriptionClaim(value: claim))
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteDistribution)
        alertController.addAction(cancel)

        self.present(alertController, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].details().count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].stringValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell") else {
            return UITableViewCell()
        }
        
        let setting = self.sections[indexPath.section].details()[indexPath.row]
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
        case .date:
            if let date = export?.metadata.commit.date {
                cell.detailTextLabel?.text = dateFormatter.string(from: date)
            }
        case .deploymentTarget:
            cell.detailTextLabel?.text = export?.metadata.deployment.target
        case .configuration:
            cell.detailTextLabel?.text = export?.metadata.configuration.name
        case .certificateExpiryDate:
            if let export = export, export.isExpired {
                cell.detailTextLabel?.text = "EXPIRED"
            }
            else if let certificateExpiryDate = export?.metadata.distributionSummary.certificateExpiryDate {
                cell.detailTextLabel?.text = certificateExpiryDate.duration
            } else {
                cell.detailTextLabel?.text = ""
            }
        case .distributed:
            if let modifiedAt = export?.modifiedAt {
                cell.detailTextLabel?.text = dateFormatter.string(from: modifiedAt)
            } else if let createdAt = export?.createdAt {
                cell.detailTextLabel?.text = dateFormatter.string(from: createdAt)
            }
        case .elapses:
            if let export = export, export.isElapsed {
                cell.detailTextLabel?.text = "ELAPSED"
            } else if let elapsesAt = export?.manifest.elapsesAt{
                cell.detailTextLabel?.text = elapsesAt.duration
            } else {
                cell.detailTextLabel?.text = ""
            }
        }
        
        return cell

    }

}

