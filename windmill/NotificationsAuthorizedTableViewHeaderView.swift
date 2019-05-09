//
//  NotificationsEnabledTableViewHeaderView.swift
//  windmill
//
//  Created by Markos Charatzas on 25/10/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import UIKit

class NotificationsAuthorizedTableViewHeaderView: UITableViewHeaderFooterView {
    
    class func make(width: CGFloat) -> NotificationsAuthorizedTableViewHeaderView {
        return NotificationsAuthorizedTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: width, height: 120.0))
    }
    
    @IBOutlet weak var label: UILabel! {
        didSet{
            let attributedText = NSMutableAttributedString(string: self.label?.text ?? "")
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
