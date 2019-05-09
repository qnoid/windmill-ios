//
//  TopicButton.swift
//  windmill
//
//  Created by Markos Charatzas on 08/05/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

@IBDesignable
class TopicButton: UIButton {
    
    @IBInspectable var borderWidth:CGFloat = 1.0 {
        didSet{
            self.setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let border = UIView()
        border.backgroundColor = UIColor.Windmill.grayColor
        border.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(border)
        border.addConstraint(NSLayoutConstraint(item: border,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .height,
                                                multiplier: 1, constant: 1.0))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: .bottomMargin,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .bottom,
                                              multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leadingMargin,
                                              multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailingMargin,
                                              multiplier: 1, constant: 0))
    }
}
