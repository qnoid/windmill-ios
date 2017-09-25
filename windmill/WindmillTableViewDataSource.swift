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

extension Windmill {
    var urlAsAttributedString: NSAttributedString{
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 27

        return NSAttributedString(string: "INSTALL", attributes: [
            NSAttributedStringKey.link: self.url,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium),
            NSAttributedStringKey.paragraphStyle: paragraph,
            NSAttributedStringKey.baselineOffset: 5.0])
    }
}

class WindmillTableViewDataSource: NSObject, UITableViewDataSource {
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        
        return dateFormatter
    }()
    
    var windmills: [Windmill] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.windmills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WindmillTableViewCell") as! WindmillTableViewCell
        
        let windmill = self.windmills[indexPath.row]
        
        cell.titleLabel.text = windmill.title
        cell.versionLabel.text = "\(windmill.version)"
        cell.dateLabel.text = windmill.updated_at.timestampString
        cell.installTextView.attributedText = windmill.urlAsAttributedString
        cell.installTextView.textAlignment = .center
        
        return cell
    }
}
