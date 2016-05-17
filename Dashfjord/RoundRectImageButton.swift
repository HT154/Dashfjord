//
//  RoundRectImageButton.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/26/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class RoundRectImageButton: NSButton {

    @IBInspectable var cornerRadius: CGFloat = 2 {
        didSet { setNeedsDisplayInRect(bounds) }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        NSGraphicsContext.currentContext()?.saveGraphicsState()
        NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius).setClip()
        super.drawRect(dirtyRect)
        NSGraphicsContext.currentContext()?.restoreGraphicsState()
    }
    
}
