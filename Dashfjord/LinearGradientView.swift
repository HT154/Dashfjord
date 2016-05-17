//
//  LinearGradientView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/2/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

@IBDesignable class LinearGradientView: NSView {

    @IBInspectable var startingColor: NSColor = NSColor(white: 0, alpha: 0.4) {
        didSet { setNeedsDisplayInRect(bounds) }
    }
    
    @IBInspectable var endingColor: NSColor = NSColor.clearColor() {
        didSet { setNeedsDisplayInRect(bounds) }
    }
    
    @IBInspectable var angle: CGFloat = 270 {
        didSet { setNeedsDisplayInRect(bounds) }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        NSGradient(startingColor: startingColor, endingColor: endingColor)?.drawInRect(bounds, angle: angle)
    }
    
}
