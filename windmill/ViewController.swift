//
//  ViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 04/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    var itmsURL: NSURL? {
        didSet{
            self.button.hidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var button: UIButton!
    @IBAction func foo(sender: AnyObject) {
        
        self.presentViewController(SFSafariViewController(URL: self.itmsURL!), animated: true, completion: nil)
    }
}

