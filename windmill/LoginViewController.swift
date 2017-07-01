//
//  LoginViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 26/10/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var accountTextField: UITextField! {
        didSet {
            accountTextField.delegate = self
        }
    }
    @IBOutlet weak var continueButton: UIButton! {
        didSet {
            continueButton.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navigationController = segue.destination as! UINavigationController
        
        let viewController = navigationController.topViewController as! ViewController
        
        viewController.account = self.accountTextField.text ?? ""
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let viewController = ViewController.make(for: self.accountTextField.text ?? "")
        
        present(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
        
        return true
    }
}
