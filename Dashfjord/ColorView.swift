//
//  ColorView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/21/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

@IBDesignable class ColorView: NSView {
    
    @IBInspectable var color: NSColor = NSColor.whiteColor() {
        didSet { setNeedsDisplayInRect(bounds) }
    }
    
    @IBInspectable var alternateColor: NSColor = NSColor.whiteColor() {
        didSet { setNeedsDisplayInRect(bounds) }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { setNeedsDisplayInRect(bounds) }
    }
    
    var showAlternate = false {
        didSet { setNeedsDisplayInRect(bounds) }
    }
    
    var currentColor: NSColor {
        return showAlternate ? alternateColor : color
    }
    
    override func drawRect(dirtyRect: NSRect) {
        currentColor.set()
        NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius).fill()
    }
    
}
