//
//  NotificationsEnabledTableViewHeaderView.swift
//  windmill
//
//  Created by Markos Charatzas on 25/10/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import UIKit

class NotificationsAuthorizedTableViewHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var label: UILabel! {
        didSet{
            let attributedText = NSMutableAttributedString(string: "You will receive a notification when a ")
            attributedText.append(NSAttributedString(string: "New build", attributes: [.foregroundColor : UIColor.black, .font : UIFont.boldSystemFont(ofSize: 14)]))
            attributedText.append(NSAttributedString(string: " is "))
            attributedText.append(NSAttributedString(string: "deployed", attributes: [.foregroundColor : UIColor.Windmill.pinkColor]))
            attributedText.append(NSAttributedString(string: "."))
            label.attributedText = attributedText
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        wml_addSubview(view: wml_load(view: NotificationsAuthorizedTableViewHeaderView.self), layout: { view in
            wml_layout(view)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        wml_addSubview(view: wml_load(view: NotificationsAuthorizedTableViewHeaderView.self), layout: { view in
            wml_layout(view)
        })
    }
}
