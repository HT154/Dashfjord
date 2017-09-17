//
//  ColorView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/21/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

@IBDesignable class ColorView: NSView {
    
    @IBInspectable var color: NSColor = NSColor.white {
        didSet { setNeedsDisplay(bounds) }
    }
    
    @IBInspectable var alternateColor: NSColor = NSColor.white {
        didSet { setNeedsDisplay(bounds) }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { setNeedsDisplay(bounds) }
    }
    
    var showAlternate = false {
        didSet { setNeedsDisplay(bounds) }
    }
    
    var currentColor: NSColor {
        return showAlternate ? alternateColor : color
    }
    
    override func draw(_ dirtyRect: NSRect) {
        currentColor.set()
        NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius).fill()
    }
    
}
