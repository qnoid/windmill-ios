//
//  InstallTableViewFooterView.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 25/10/2017.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
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
