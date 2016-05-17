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
        didSet { setNeedsDisplayInRect(bounds) }
    }
    
    @IBInspectable var color = Utils.bodyTextColor {
        didSet { setNeedsDisplayInRect(bounds) }
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    init() {
        super.init(frame: NSZeroRect)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        color.set()
        
        let rect = NSBezierPath(ovalInRect: NSMakeRect(1, bounds.size.height - 15, 5, 5))
        rect.stroke()
        
        if fill {
            rect.fill()
        }
    }
    
}
