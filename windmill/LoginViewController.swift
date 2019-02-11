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
    
    @IBOutlet weak var questionImageView: UIImageView!
    
    var applicationStorage: ApplicationStorage = ApplicationStorage.default
    
    static func make(applicationStorage: ApplicationStorage = ApplicationStorage.default) -> LoginViewController? {
        
        let loginViewController = Storyboards.main().instantiateViewController(withIdentifier: String(describing: self)) as? LoginViewController
        
        loginViewController?.applicationStorage = applicationStorage
        
        return loginViewController
    }
    
    @objc func didTouchUpInsideClose(_ sender: Notification) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.questionImageView.tintColor = self.view.tintColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let navigationController = segue.destination as? UINavigationController else {
            return
        }
        
        guard let mainViewController = navigationController.topViewController as? MainViewController else {
            return
        }
        navigationController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(didTouchUpInsideClose(_:)))
        
        let account = self.accountTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
        mainViewController.account = account
        
        try? applicationStorage.write(value: account, key: .account, options: .completeFileProtectionUntilFirstUserAuthentication)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let navigationController = Storyboards.main().instantiateViewController(withIdentifier: "MainNavigationViewController") as? UINavigationController else {
            return false
        }
        
        guard let viewController = navigationController.topViewController as? MainViewController else {
            return false
        }
        navigationController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(didTouchUpInsideClose(_:)))

        let account = self.accountTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""
        viewController.account = account
        
        present(navigationController, animated: true)
        
        try? applicationStorage.write(value: account, key: .account, options: .completeFileProtectionUntilFirstUserAuthentication)
        
        textField.resignFirstResponder()
        return true
    }
}
