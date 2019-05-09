//
//  InstallTableViewFooterView.swift
//  windmill
//
//  Created by Markos Charatzas on 25/10/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import UIKit

class InstallTableViewFooterView: UITableViewHeaderFooterView {
    
    static func make(width: CGFloat) -> InstallTableViewFooterView {
        return InstallTableViewFooterView(frame: CGRect(x: 0, y: 0, width: width, height: 160.0))
    }
    @IBOutlet weak var textView: UITextView!{
        didSet{
            let attributedText = NSMutableAttributedString(string: "This ", attributes: [.font :  UIFont.preferredFont(forTextStyle: .callout)])
            
            if let url = URL(string: "https://help.apple.com/developer-account/#/dev40df0d9fa") {
                attributedText.append(NSAttributedString(string: "device must be registered", attributes: [.link: url, .font :  UIFont.preferredFont(forTextStyle: .callout)]))
            }
            
            attributedText.append(NSAttributedString(string: " in the Apple Developer Account to be able to install an application that Windmill on the Mac distributes.", attributes: [.font :  UIFont.preferredFont(forTextStyle: .callout)]))
            textView.attributedText = attributedText
        }
    }
    @IBOutlet weak var label: UILabel!

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
