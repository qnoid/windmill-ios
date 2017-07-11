//
//  UIAlertController+Windmill.swift
//  windmill
//
//  Created by Markos Charatzas on 06/07/2017.
//  Copyright © 2017 Windmill. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    struct Windmill {
        
        static func make(error: Error?) -> UIAlertController {
            let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            return alertController
        }
    }
}
