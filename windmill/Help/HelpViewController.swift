//
//  HelpViewController.swift
//  windmill
//
//  Created by Markos Charatzas on 08/05/2019.
//  Copyright © 2019 Windmill. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    class func make(storyboard: UIStoryboard = WindmillApp.Storyboard.help()) -> HelpViewController? {
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? HelpViewController
        
        return viewController
    }

    @IBOutlet weak var textView: UITextView! {
        didSet {
            let string = NSLocalizedString("io.windmill.windmill.help.welcome.message", comment: "")
            let attributedText = NSMutableAttributedString(string: string, attributes:[.font: UIFont.preferredFont(forTextStyle: .body)])
            
            attributedText.addAttribute(.font, value: UIFont.preferredFont(forTextStyle: .headline), range: (string as NSString).range(of: "#PoweredByWindmill"))
            
            self.textView.attributedText = attributedText
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
