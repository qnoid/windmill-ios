//
//  OpenStoreTableViewFooterView.swift
//  windmill
//
//  Created by Markos Charatzas on 12/02/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit


class OpenStoreTableViewFooterView: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        wml_addSubview(view: wml_load(view: type(of:self)), layout: { view in
            wml_layout(view)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        wml_addSubview(view: wml_load(view: type(of:self)), layout: { view in
            wml_layout(view)
        })
    }
}
