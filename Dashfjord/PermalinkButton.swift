//
//  PermalinkButton.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/8/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

@IBDesignable class PermalinkButton: NSButton {
    
    var trackingRect: NSTrackingRectTag?
    var folded = false
    
    override func viewDidMoveToWindow() {
        trackingRect = addTrackingRect(bounds, owner: self, userData: nil, assumeInside: false)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if folded {
            NSColor(white: 193.0/255, alpha: 1).set()
            
            var rrect = bounds
            rrect.size.width += 10
            rrect.size.height += 10
            rrect.origin.y -= 10
            
            NSBezierPath(roundedRect: rrect, xRadius: 3, yRadius: 3).fill()
            
            if let background = window?.contentView as? ColorView {
                background.currentColor.set()
            } else {
                Utils.tumblrBlue.set()
            }
            
            let clipper = NSBezierPath()
            clipper.move(to: NSPoint(x: 0, y: 0))
            clipper.line(to: NSPoint(x: bounds.size.width, y: 0))
            clipper.line(to: NSPoint(x: bounds.size.width, y: bounds.size.height))
            clipper.close()
            clipper.fill()
        }
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        folded = true
        setNeedsDisplay(bounds)
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        folded = false
        setNeedsDisplay(bounds)
    }
    
}
