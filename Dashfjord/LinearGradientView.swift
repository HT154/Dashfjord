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
        didSet { setNeedsDisplay(bounds) }
    }
    
    @IBInspectable var endingColor: NSColor = NSColor.clear {
        didSet { setNeedsDisplay(bounds) }
    }
    
    @IBInspectable var angle: CGFloat = 270 {
        didSet { setNeedsDisplay(bounds) }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSGradient(starting: startingColor, ending: endingColor)?.draw(in: bounds, angle: angle)
    }
    
}
