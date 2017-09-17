//
//  PostStackView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 11/17/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostStackView: WidthStretchingStackView {

    override func draw(_ dirtyRect: NSRect) {
        NSColor(calibratedWhite: 1.0, alpha: 1.0).set()
        NSBezierPath(roundedRect: NSMakeRect(0, 0, bounds.size.width, bounds.size.height), xRadius: 3, yRadius: 3).fill()
    }
    
}
