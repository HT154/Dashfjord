//
//  TumblrButton.swift
//  Dashfjord
//
//  Created by Joshua Basch on 11/27/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

@IBDesignable class TumblrButton: NSButton {
    
    let color = NSColor(calibratedRed: 64.0/255, green: 139.0/255, blue: 195.0/255, alpha: 1)
    let textColor = NSColor.whiteColor()
    let textFont = Font.get(weight: .Bold, size: 16)
    let center: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = NSCenterTextAlignment
        
        return style
    }()
    
    override var title: String {
        set {
            attributedTitle = NSAttributedString(string: title, attributes: [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: center])
        }
        get { return attributedTitle.string }
    }
    
    override func awakeFromNib() {
        attributedTitle = NSAttributedString(string: title, attributes: [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: center])
    }
    
    override func drawRect(dirtyRect: NSRect) {
        color.set()
        NSBezierPath(roundedRect: bounds, xRadius: 2, yRadius: 2).fill()
        
        super.drawRect(dirtyRect)
    }
    
}
