//
//  WindmillTableViewDataSource.swift
//  windmill
//
//  Created by Markos Charatzas on 29/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit

extension Date {
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        
        guard let timeString = formatter.string(from: self, to: Date(timeIntervalSinceNow: 60)) else {
            return nil
        }
        
        let formatString = NSLocalizedString("%@ ago", comment: "")
        
        return String(format: formatString, timeString)
    }
}

extension Export {
    var urlAsAttributedString: NSAttributedString{
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 27

        return NSAttributedString(string: "INSTALL", attributes: [
            NSAttributedString.Key.link: self.url,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium),
            NSAttributedString.Key.paragraphStyle: paragraph,
            NSAttributedString.Key.baselineOffset: 5.0])
    }
}

class WindmillTableViewDataSource: NSObject, UITableViewDataSource {
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        
        return dateFormatter
    }()
    
    var exports: [Export] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WindmillTableViewCell") as! WindmillTableViewCell
        
        let bundle = self.exports[indexPath.row]
        
        cell.titleLabel.text = bundle.title
        cell.versionLabel.text = "\(bundle.version)"
        cell.dateLabel.text = bundle.modifiedAt.timestampString
        cell.installTextView.attributedText = bundle.urlAsAttributedString
        cell.installTextView.textAlignment = .center
        
        return cell
    }
}
