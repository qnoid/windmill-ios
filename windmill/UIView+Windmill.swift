//
//  UIView+Windmill.swift
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

extension UIView {
    
    func wml_load<T: UIView>(view: T.Type) -> UIView {
        let views = Bundle(for: type(of: self)).loadNibNamed(String(describing: view), owner: self) as! [UIView]
        let view = views[0]
        return view
    }
}

extension UITableViewCell {
    
    func wml_layout(_ view: UIView) {
        self.contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func wml_addSubview(view: UIView, layout: (_ view: UIView) -> Void) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(view)
        layout(view)
    }
}

extension UITableViewHeaderFooterView {
    
    func wml_layout(_ view: UIView) {
        self.contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func wml_addSubview(view: UIView, layout: (_ view: UIView) -> Void) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(view)
        layout(view)
    }
}
