//
//  ExportTableViewCell.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 29/05/2016.
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
import QuartzCore

protocol ExportTableViewCellDelegate: class {
    func tableViewCell(_ cell: ExportTableViewCell, installButtonTapped: InstallButton, forExport export: Export)
}

class ExportTableViewCell: UITableViewCell, UITextViewDelegate, NSLayoutManagerDelegate, InstallButtonTouchRecognizer {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var commitLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var installButton: InstallButton! {
        didSet {
            self.installButton.delegate = self
            self.installButton.touchRecognizer = self
        }
    }
    @IBOutlet weak var iconImageVIew: UIImageView!
    
    weak var delegate: ExportTableViewCellDelegate?
    
    var export: Export? {
        didSet {
            titleLabel?.text = export?.title
            if let version = export?.version {
                versionLabel?.text = "\(version)"
            }
            if let shortSha = export?.metadata.commit.shortSha {
                commitLabel?.text = "(\(shortSha))"
            }

            dateLabel?.text = export?.modifiedAt?.ago ?? export?.createdAt.ago
            installButton?.attributedText = export?.urlAsAttributedString()
            installButton?.textAlignment = .center
            if let isAvailable = export?.isAvailable() {
                installButton?.isSelectable = isAvailable
            }
        }
    }
    
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
        let installButton = self.installButton.hitTest(self.installButton.convert(point, from: self), with: event)
        return installButton ?? super.hitTest(point, with: event)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.iconImageVIew.layer.cornerRadius = 10.0
        self.iconImageVIew.layer.masksToBounds = true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        DispatchQueue.main.async {
            textView.selectedTextRange = nil //so no selection carrots appear
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.isHighlighted = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.isHighlighted = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.isHighlighted = false
    }

    func didTouchUpInside(_ button: InstallButton) {
        if let export = export {
            self.delegate?.tableViewCell(self, installButtonTapped: button, forExport: export)
        }
    }
}
