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
        
        static func make(title: String, error: Error) -> UIAlertController {
            let alertController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            
            return alertController
        }
        
        static func make(error: WindmillError) -> UIAlertController {
            let message = "\(error.errorDescription ?? "") \(error.failureReason ?? "") \(error.recoverySuggestion ?? "")"
            let alertController = UIAlertController(title: error.errorTitle ?? "Error", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            
            return alertController
        }
    }
}
