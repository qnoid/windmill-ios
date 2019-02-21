//
//  MainTableViewHeaderView.swift
//  windmill
//
//  Created by Markos Charatzas on 25/10/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import UIKit

class MainTableViewHeaderView: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        wml_addSubview(view: wml_load(view: MainTableViewHeaderView.self), layout: { view in
            wml_layout(view)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        wml_addSubview(view: wml_load(view: MainTableViewHeaderView.self), layout: { view in
            wml_layout(view)
        })
    }
}
