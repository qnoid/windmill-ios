//
//  WindmillTextView.swift
//  windmill
//
//  Created by Markos Charatzas on 30/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable class WindmillTextView: UITextView {

    var highlighted: Bool = false {
        didSet {
            if(highlighted) {
                self.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
                self.backgroundColor = UIColor.Windmill.greenColor
            } else {
                self.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.Windmill.greenColor]
                self.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return super.hitTest(point, withEvent: event)        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textContainer.size = self.bounds.size
        self.textContainerInset = UIEdgeInsetsZero
        self.layer.borderColor = UIColor.Windmill.greenColor.CGColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }
}