//
//  Button.swift
//  windmill
//
//  Created by Markos Charatzas on 25/10/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
class Button: UIButton {
    
    @IBInspectable var cornerRadius:CGFloat = 5.0 {
        didSet{
            self.setNeedsLayout()
        }
    }

    @IBInspectable var borderWidth:CGFloat = 1.0 {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderColor = self.titleColor(for: .normal)?.cgColor
        self.layer.borderWidth = self.borderWidth
        self.layer.cornerRadius = self.cornerRadius
        self.layer.masksToBounds = true
    }
}
