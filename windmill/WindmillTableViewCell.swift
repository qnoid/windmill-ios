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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(view: load(view: WindmillTableViewCell.self), layout: { view in
            layout(view)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addSubview(view: load(view: WindmillTableViewCell.self), layout: { view in
            layout(view)
        })
    }
    
    private func layout(_ view: UIView) {
        self.contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func load<T: UIView>(view: T.Type) -> UIView {
        let views = Bundle(for: type(of: self)).loadNibNamed(String(describing: view), owner: self) as! [UIView]
        let view = views[0]
        return view
    }
    
    func addSubview(view: UIView, layout: (_ view: UIView) -> Void) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(view)
        layout(view)
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
