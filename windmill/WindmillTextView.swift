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
                self.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
                self.backgroundColor = UIColor.Windmill.greenColor
            } else {
                self.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.Windmill.greenColor]
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return super.hitTest(point, with: event)        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textContainer.size = self.bounds.size
        self.textContainerInset = UIEdgeInsets.zero
        self.layer.borderColor = UIColor.Windmill.greenColor.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }
}
