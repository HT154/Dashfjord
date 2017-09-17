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
    
    @IBInspectable var activeTint: NSColor = NSColor.black {
        didSet { setNeedsDisplay() }
    }
    
    var tintActive = false {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        (tintActive ? activeTint : inactiveTint).set()
        NSRectFillUsingOperation(bounds, NSCompositingOperation.sourceAtop)
    }
    
}
