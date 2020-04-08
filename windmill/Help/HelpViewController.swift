//
//  HelpViewController.swift
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
