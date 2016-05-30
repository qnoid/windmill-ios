//
//  WindmillTableViewCell.swift
//  windmill
//
//  Created by Markos Charatzas on 29/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit

class WindmillTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var installTextView: UITextView! {
        didSet {
            self.installTextView.layer.borderColor = UIColor(red: 3/255, green: 167/255, blue: 255/255, alpha: 1.0).CGColor
            self.installTextView.layer.borderWidth = 1.0
            self.installTextView.layer.cornerRadius = 6.0
            self.installTextView.layer.masksToBounds = true
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return self.installTextView
    }
}