//
//  WindmillTableViewCell.swift
//  windmill
//
//  Created by Markos Charatzas on 29/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit
extension UIColor {
    struct Windmill {
        static let blueColor = UIColor(red: 3/255, green: 167/255, blue: 255/255, alpha: 1.0)
    }
}

class WindmillTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var installTextView: UITextView! {
        didSet {
            self.installTextView.textContainer.size = self.installTextView.bounds.size
            self.installTextView.layer.borderColor = UIColor.Windmill.blueColor.CGColor
            self.installTextView.layer.borderWidth = 1.5
            self.installTextView.layer.cornerRadius = 5.0
            self.installTextView.layer.masksToBounds = true
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        let point = self.installTextView.convertPoint(point, fromView: self)
        
        return self.installTextView.hitTest(point, withEvent: event)
    }
}