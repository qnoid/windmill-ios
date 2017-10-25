//
//  UIView+Windmill.swift
//  windmill
//
//  Created by Markos Charatzas on 25/10/2017.
//  Copyright © 2017 Windmill. All rights reserved.
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
