//
//  TextTintButton.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/24/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class TextTintButton: NSButton {

    @IBInspectable var bold: Bool = false {
        didSet { setToAttributed() }
    }
    
    @IBInspectable var fontSize: CGFloat = 13 {
        didSet { setToAttributed() }
    }
    
    @IBInspectable var color: NSColor = NSColor(calibratedWhite: (160.0/255), alpha: 1.0) {
        didSet { setToAttributed() }
    }
    
    override var title: String {
        set {
            super.title = newValue
            setToAttributed()
        }
        get { return super.title }
    }
    
    func setToAttributed() {
        attributedTitle = NSAttributedString(string: title, attributes: [NSFontAttributeName: Font.get(weight: bold ? .Bold : .Regular, size: fontSize), NSForegroundColorAttributeName: color])
    }
    
}
