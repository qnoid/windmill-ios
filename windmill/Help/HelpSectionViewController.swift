//
//  HelpSectionViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 08/05/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class HelpSectionViewController: UIViewController {

    class func make(section: (HelpTableViewController.Section, HelpTableViewController.Child), storyboard: UIStoryboard = WindmillApp.Storyboard.help()) -> HelpSectionViewController? {
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? HelpSectionViewController
        viewController?.section = section
        
        return viewController
    }

    typealias Section = HelpTableViewController.Section
    typealias Child = HelpTableViewController.Child
    
    @IBOutlet weak var childLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var section: (section: Section, child: Child)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.section?.section.stringValue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.childLabel.text = self.section?.child.stringValue
        self.textView.attributedText = self.section?.child.message
    }
}
