//
//  RoundRectImageView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/4/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class RoundRectImageView: NSImageView {

    @IBInspectable var cornerRadius: CGFloat = 2 {
        didSet { setNeedsDisplay(bounds) }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.current()?.saveGraphicsState()
        NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius).setClip()
        super.draw(dirtyRect)
        NSGraphicsContext.current()?.restoreGraphicsState()
    }
    
}
