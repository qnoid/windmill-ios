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
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderColor = self.tintColor.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }
}
