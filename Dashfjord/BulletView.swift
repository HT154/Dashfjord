//
//  BulletView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/31/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class BulletView: NSView {

    @IBInspectable var fill = true {
        didSet { setNeedsDisplay(bounds) }
    }
    
    @IBInspectable var color = Utils.bodyTextColor {
        didSet { setNeedsDisplay(bounds) }
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    init() {
        super.init(frame: NSZeroRect)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        color.set()
        
        let rect = NSBezierPath(ovalIn: NSMakeRect(1, bounds.size.height - 15, 5, 5))
        rect.stroke()
        
        if fill {
            rect.fill()
        }
    }
    
}
