//
//  ExportTableViewCell.swift
//  windmill
//
//  Created by Markos Charatzas on 29/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit
import QuartzCore

class ExportTableViewCell: UITableViewCell, UITextViewDelegate, NSLayoutManagerDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var installTextView: WindmillTextView! {
        didSet {
            self.installTextView.delegate = self
        }
    }
    @IBOutlet weak var iconImageVIew: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        wml_addSubview(view: wml_load(view: ExportTableViewCell.self), layout: { view in
            wml_layout(view)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        wml_addSubview(view: wml_load(view: ExportTableViewCell.self), layout: { view in
            wml_layout(view)
        })
    }
    
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
