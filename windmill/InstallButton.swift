//
//  WindmillTextView.swift
//  windmill
//
//  Created by Markos Charatzas on 30/05/2016.
//  Copyright © 2016 Windmill. All rights reserved.
//

import UIKit
import QuartzCore

protocol InstallButtonTouchRecognizer: class {
    func didTouchUpInside(_ button: InstallButton)
}

@IBDesignable class InstallButton: UITextView {

    var highlighted: Bool = false {
        didSet {
            let foregroundColor: UIColor
            let backgroundColor: UIColor
            
            switch (self.isSelectable, self.highlighted) {
            case (true, true):
                foregroundColor = .white
                backgroundColor = UIColor.Windmill.pinkColor
            case (false, true):
                foregroundColor = .black
                backgroundColor = .gray
            case (true, false):
                foregroundColor = UIColor.Windmill.pinkColor
                backgroundColor = .white
            case (false, false):
                foregroundColor = UIColor.Windmill.pinkColor
                backgroundColor = .white
            }
            self.linkTextAttributes = [NSAttributedString.Key.foregroundColor: foregroundColor]
            self.backgroundColor = backgroundColor
        }
    }
    
    override var isSelectable: Bool {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    weak var touchRecognizer: InstallButtonTouchRecognizer?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return super.hitTest(point, with: event)        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textContainer.size = self.bounds.size
        self.textContainerInset = UIEdgeInsets.zero
    }
    
    override func draw(_ rect: CGRect) {
        self.layer.borderColor = self.isSelectable ? UIColor.Windmill.pinkColor.cgColor : UIColor.gray.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.highlighted = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {        
        self.highlighted = false
        
        if let point = touches.first?.location(in: self), self.point(inside: point, with: event) {
            self.touchRecognizer?.didTouchUpInside(self)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.highlighted = false
    }
}
