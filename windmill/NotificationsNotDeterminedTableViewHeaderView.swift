//
//  InstallTableViewHeaderView.swift
//  windmill
//
//  Created by Markos Charatzas on 25/10/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import UIKit

protocol NotifyTableViewHeaderViewDelegate: NSObjectProtocol {
    func didTouchUpInsideAuthorizeButton(_ headerView: NotificationsNotDeterminedTableViewHeaderView, button: UIButton)
}

class NotificationsNotDeterminedTableViewHeaderView: UITableViewHeaderFooterView {
    
    class func make(width: CGFloat) -> NotificationsNotDeterminedTableViewHeaderView {
        return NotificationsNotDeterminedTableViewHeaderView(frame: CGRect(x: 0, y: 0, width: width, height: 66.0))
    }
    
    @IBOutlet weak var notifyButton: Button! {
        didSet{
            let attributedText = NSMutableAttributedString(string: self.notifyButton.titleLabel?.text ?? "")
            notifyButton.setAttributedTitle(attributedText, for: .normal)
        }
    }
    
    weak var delegate: NotifyTableViewHeaderViewDelegate?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        wml_addSubview(view: wml_load(view: NotificationsNotDeterminedTableViewHeaderView.self), layout: { view in
            wml_layout(view)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        wml_addSubview(view: wml_load(view: NotificationsNotDeterminedTableViewHeaderView.self), layout: { view in
            wml_layout(view)
        })
    }
    
    @IBAction func didTouchUpInsideAuthorizeButton(_ sender: UIButton) {
        self.delegate?.didTouchUpInsideAuthorizeButton(self, button: sender)
    }
}
