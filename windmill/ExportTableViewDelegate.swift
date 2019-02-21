//
//  WindmillTableViewDelegate.swift
//  windmill
//
//  Created by Markos Charatzas on 31/10/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit

class ExportTableViewDelegate: NSObject, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 107
    }    
}
