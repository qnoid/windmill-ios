//
//  ExportTableViewDataSource.swift
//  windmill
//
//  Created by Markos Charatzas on 29/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit

extension Date {
    
    var duration: String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        
        guard let timeString = formatter.string(from: Date(), to: self) else {
            return nil
        }
        
        let formatString = NSLocalizedString("In %@", comment: "")
        
        return String(format: formatString, timeString)
    }

    var ago: String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        
        guard let timeString = formatter.string(from: self, to: Date()) else {
            return nil
        }
        
        let formatString = NSLocalizedString("%@ ago", comment: "")
        
        return String(format: formatString, timeString)
    }
}

extension Export {
    
    func isAvailable() -> Bool {
        return !self.isExpired && self.isCompatible()
    }    

    func isCompatible(device: UIDevice = UIDevice.current) -> Bool {
        return self.targetsEqualOrLowerThan(version: device.systemVersion)
    }
     
    var status: Export.Status {
        switch (self.isExpired, self.isCompatible()) {
        case (_, false):
            return .error(.incompatible(target: self.metadata.deployment.target))
        case (true, _):
            return .error(.expired)
        case (false, _):
            return .ok
        }
    }

    func urlAsAttributedString() -> NSAttributedString {
        
        switch self.status {
        case .error(let error):
            switch error {
            case .incompatible:
                let paragraph = NSMutableParagraphStyle()
                paragraph.minimumLineHeight = 27
                
                return NSAttributedString(string: "DISABLED", attributes: [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.bold),
                    .paragraphStyle: paragraph,
                    .baselineOffset: 5.0])
            case .expired:
                let paragraph = NSMutableParagraphStyle()
                paragraph.minimumLineHeight = 27
                
                return NSAttributedString(string: "EXPIRED", attributes: [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.bold),
                    .paragraphStyle: paragraph,
                    .baselineOffset: 5.0])
            }
        case .ok:
            let paragraph = NSMutableParagraphStyle()
            paragraph.minimumLineHeight = 27
            
            return NSAttributedString(string: "INSTALL", attributes: [
                .link: self.url,
                .foregroundColor: UIColor.Windmill.pinkColor,
                .font: UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium),
                .paragraphStyle: paragraph,
                .baselineOffset: 5.0])
        }
    }
}

class ExportTableViewDataSource: NSObject, UITableViewDataSource {
    
    var exports: [Export] = []
    
    weak var controller: AppsViewController?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExportTableViewCell") as? ExportTableViewCell else {
            return UITableViewCell()
        }
        
        let export = self.exports[indexPath.row]
        cell.accessoryType = .detailButton
        
        cell.delegate = controller
        cell.export = export
        
        return cell
    }
}
