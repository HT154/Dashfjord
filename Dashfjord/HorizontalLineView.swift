//
//  HorizontalLineView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/25/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class HorizontalLineView: NSView {
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    init() {
        super.init(frame: NSZeroRect)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 1.0).isActive = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor(calibratedWhite: (231.0 / 255), alpha: 1.0).set()
        NSBezierPath(rect: dirtyRect).fill()
    }
    
}
