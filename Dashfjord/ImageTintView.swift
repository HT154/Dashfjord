//
//  ImageTintView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/24/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

@IBDesignable class ImageTintView: NSImageView {

    @IBInspectable var inactiveTint: NSColor = NSColor(calibratedWhite: (160.0/255), alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var activeTint: NSColor = NSColor.blackColor() {
        didSet { setNeedsDisplay() }
    }
    
    var tintActive = false {
        didSet { setNeedsDisplay() }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        (tintActive ? activeTint : inactiveTint).set()
        NSRectFillUsingOperation(bounds, NSCompositingOperation.CompositeSourceAtop)
    }
    
}
