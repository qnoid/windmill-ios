//
//  WindmillTableViewCell.swift
//  windmill
//
//  Created by Markos Charatzas on 29/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit
import QuartzCore

extension UIColor {
    struct Windmill {
        static let greenColor = UIColor(red: 0/255, green: 179/255, blue: 0/255, alpha: 1.0)
        static let blueColor = UIColor(red: 3/255, green: 167/255, blue: 255/255, alpha: 1.0)
    }
}

class WindmillTableViewCell: UITableViewCell, UITextViewDelegate, NSLayoutManagerDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var installTextView: WindmillTextView! {
        didSet {
            self.installTextView.delegate = self
        }
    }
    @IBOutlet weak var iconImageVIew: UIImageView!
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let point = self.installTextView.convert(point, from: self)
        
        let view = self.installTextView.hitTest(point, with: event)
        
        if self.installTextView.isEqual(view) {
            self.installTextView.highlighted = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                self.installTextView.highlighted = false //make sure its unhighlighted in case of touch cancelled failure
            }
        }
        
        return view;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.iconImageVIew.layer.cornerRadius = 10.0
        self.iconImageVIew.layer.masksToBounds = true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil //so no selection carrots appear
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        self.installTextView.highlighted = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.installTextView.highlighted = false
    }
}
