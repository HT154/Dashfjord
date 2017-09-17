//
//  SelectionCaretView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 11/26/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

@IBDesignable class SelectionCaretView: ColorView {
    
    override func draw(_ dirtyRect: NSRect) {
        currentColor.set()
        
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 0, y: 0))
        path.line(to: NSPoint(x: 0, y: bounds.size.height))
        path.curve(to: NSPoint(x: 0, y: 0), controlPoint1: NSPoint(x: bounds.size.width, y: bounds.size.height/4), controlPoint2: NSPoint(x: bounds.size.width, y: bounds.size.height - bounds.size.height/4))
        path.close()
        
        path.fill()
    }
    
}
