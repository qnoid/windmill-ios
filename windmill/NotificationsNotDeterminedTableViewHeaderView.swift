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
    
    
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var notifyButton: Button! {
        didSet{
            let attributedText = NSMutableAttributedString(string: "Notify me when a ")
            attributedText.append(NSAttributedString(string: "New build", attributes: [.foregroundColor : UIColor.black, .font : UIFont.boldSystemFont(ofSize: 14)]))
            attributedText.append(NSAttributedString(string: " is "))
            attributedText.append(NSAttributedString(string: "deployed", attributes: [.foregroundColor : UIColor.Windmill.pinkColor]))
            attributedText.append(NSAttributedString(string: "."))
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
