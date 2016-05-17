//
//  ActionView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/26/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

@IBDesignable class ActionView: NSView {
    
    private static let types = [
        NoteType.Answer: (NSColor(calibratedWhite: 4.0/15, alpha: 1.0), NSImage(named: "action_answer")!),
        NoteType.Follow: (NSColor(calibratedRed: 93.0/255, green: 115.0/255, blue: 141.0/255, alpha: 1.0), NSImage(named: "action_follow")!),
        NoteType.Like: (NSColor(calibratedRed: 217.0/255, green: 94.0/255, blue: 64.0/255, alpha: 1.0), NSImage(named: "action_like")!),
        NoteType.Reblog: (NSColor(calibratedRed: 86.0/255, green: 188.0/255, blue: 138.0/255, alpha: 1.0), NSImage(named: "action_reblog")!),
        NoteType.Reply: (NSColor(calibratedRed: 53.0/255, green: 141.0/255, blue: 215.0/255, alpha: 1.0), NSImage(named: "action_reply")!),
        NoteType.Posted: (NSColor(calibratedRed: 93.0/255, green: 115.0/255, blue: 141.0/255, alpha: 1.0), NSImage(named: "action_posted")!),
    ]
    
    var color = NSColor.blackColor() {
        didSet { setNeedsDisplayInRect(bounds) }
    }
    
    var image = NSImage(named: "action_posted")! {
        didSet { setNeedsDisplayInRect(bounds) }
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    init() {
        super.init(frame: NSZeroRect)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setType(type: NoteType) {
        (color, image) = ActionView.types[type]!
        setNeedsDisplayInRect(bounds)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        color.set()
        NSBezierPath(ovalInRect: bounds).fill()
        
        var imageFrame = NSZeroRect
        imageFrame.size = image.size
        
        imageFrame.origin.x = NSMidX(bounds) - imageFrame.size.width / 2
        imageFrame.origin.y = NSMidY(bounds) - imageFrame.size.height / 2
        
        image.drawInRect(NSIntegralRect(imageFrame))
    }
    
}
