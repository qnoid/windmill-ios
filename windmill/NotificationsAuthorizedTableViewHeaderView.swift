//
//  NotificationsEnabledTableViewHeaderView.swift
//  windmill
//
//  Created by Markos Charatzas on 25/10/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import UIKit

class NotificationsAuthorizedTableViewHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var label: UILabel! {
        didSet{
            let attributedText = NSMutableAttributedString(string: "You will receive a notification when Windmill on the Mac ")
            attributedText.append(NSAttributedString(string: "distributes", attributes: [.foregroundColor : UIColor.Windmill.pinkColor]))
            attributedText.append(NSAttributedString(string: " a new build", attributes: [.foregroundColor : UIColor.black, .font : UIFont.boldSystemFont(ofSize: 14)]))
            attributedText.append(NSAttributedString(string: " for an application."))
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
