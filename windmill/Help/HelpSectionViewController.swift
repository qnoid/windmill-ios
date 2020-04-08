//
//  HelpSectionViewController.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 08/05/2019.
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
