//
//  NotificationsDisabledTableViewHeaderView.swift
//  windmill
//
//  Created by Markos Charatzas on 25/10/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import UIKit

protocol NotificationsDisabledTableViewHeaderViewDelegate: NSObjectProtocol {
    func didTouchUpInsideOpenSettingsButton(_ headerView: NotificationsDeniedTableViewHeaderView, button: UIButton)
}

class NotificationsDeniedTableViewHeaderView: UITableViewHeaderFooterView {
    
    
    weak var delegate: NotificationsDisabledTableViewHeaderViewDelegate?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        wml_addSubview(view: wml_load(view: NotificationsDeniedTableViewHeaderView.self), layout: { view in
            wml_layout(view)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        wml_addSubview(view: wml_load(view: NotificationsDeniedTableViewHeaderView.self), layout: { view in
            wml_layout(view)
        })
    }
    
    @IBAction func didTouchUpInsideOpenSettingsButton(_ sender: UIButton) {
        self.delegate?.didTouchUpInsideOpenSettingsButton(self, button: sender)
    }
}
