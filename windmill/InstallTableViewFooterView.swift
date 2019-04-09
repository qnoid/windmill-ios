//
//  InstallTableViewFooterView.swift
//  windmill
//
//  Created by Markos Charatzas on 25/10/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import UIKit

class InstallTableViewFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var label: UILabel! {
        didSet{
            let attributedText = NSMutableAttributedString(string: "This device must be registered in the developer profile to be able to ")
            attributedText.append(NSAttributedString(string: "INSTALL", attributes: [.foregroundColor : UIColor.Windmill.greenColor]))
            attributedText.append(NSAttributedString(string: " apps "))
            attributedText.append(NSAttributedString(string: "distributed", attributes: [.foregroundColor : UIColor.Windmill.pinkColor]))
            attributedText.append(NSAttributedString(string: " by Windmill."))
            label.attributedText = attributedText
        }
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        wml_addSubview(view: wml_load(view: type(of: self)), layout: { view in
            wml_layout(view)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        wml_addSubview(view: wml_load(view: type(of: self)), layout: { view in
            wml_layout(view)
        })
    }
}
