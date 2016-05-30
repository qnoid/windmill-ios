//
//  WindmillTableViewDataSource.swift
//  windmill
//
//  Created by Markos Charatzas on 29/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit

extension NSDate {
    var timestampString: String? {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.Year, .Month, .Day, .Hour, .Minute, .Second]
        
        guard let timeString = formatter.stringFromDate(self, toDate: NSDate(timeIntervalSinceNow: 10)) else {
            return nil
        }
        
        let formatString = NSLocalizedString("%@ ago", comment: "")
        
        return String(format: formatString, timeString)
    }
}

extension Windmill {
    var urlAsAttributedString: NSAttributedString{
        return NSAttributedString(string: "GET", attributes: [NSLinkAttributeName: self.url])
    }
}

class WindmillTableViewDataSource: NSObject, UITableViewDataSource {
    
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .MediumStyle
        
        return dateFormatter
    }()
    
    var windmills: [Windmill] = []
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return windmills.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WindmillTableViewCell") as! WindmillTableViewCell
        
        let windmill = windmills[indexPath.row]
        
        cell.titleLabel.text = windmill.title
        cell.versionLabel.text = "\(windmill.version)"
        cell.dateLabel.text = windmill.updated_at.timestampString
        cell.installTextView.attributedText = windmill.urlAsAttributedString
        cell.installTextView.textAlignment = .Center
        
        return cell
    }
}