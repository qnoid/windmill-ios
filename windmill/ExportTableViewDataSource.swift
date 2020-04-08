//
//  ExportTableViewDataSource.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 29/05/2016.
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
        return !self.isElapsed && !self.isExpired && self.isCompatible()
    }    

    func isCompatible(device: UIDevice = UIDevice.current) -> Bool {
        return self.targetsEqualOrLowerThan(version: device.systemVersion)
    }
     
    var status: Export.Status {
        switch (self.isElapsed, self.isCompatible(), self.isExpired) {
        case (true, _, _):
            return .error(.elapsed)
        case (_, false, _):
            return .error(.incompatible(target: self.metadata.deployment.target))
        case (_, _, true):
            return .error(.expired)
        case (_, _, false):
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
            case .elapsed:
                let paragraph = NSMutableParagraphStyle()
                paragraph.minimumLineHeight = 27
                
                return NSAttributedString(string: "ELAPSED", attributes: [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.bold),
                    .paragraphStyle: paragraph,
                    .baselineOffset: 5.0])
            }
        case .ok:
            let paragraph = NSMutableParagraphStyle()
            paragraph.minimumLineHeight = 27
            
            return NSAttributedString(string: "INSTALL", attributes: [
                .link: self.manifest.itms,
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
