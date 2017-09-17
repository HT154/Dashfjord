//
//  WidthStretchingStackView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/21/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class WidthStretchingStackView: NSStackView {
    
    var defaultInset: CGFloat = 0
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    init() {
        super.init(frame: NSZeroRect)
        orientation = .vertical
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    var addInsetL: CGFloat = -1
    var addInsetR: CGFloat = -1
    var flexibleRight = false
    
    func addView(_ aView: NSView, inGravity gravity: NSStackViewGravity, insetLeft: CGFloat, insetRight: CGFloat) {
        addInsetL = insetLeft
        addInsetR = insetRight
        super.addView(aView, in: gravity)
        addInsetL = -1
        addInsetR = -1
    }
    
    func addView(_ aView: NSView, inGravity gravity: NSStackViewGravity, inset: CGFloat, flexibleRight flexR: Bool = false) {
        addInsetL = inset
        addInsetR = inset
        flexibleRight = flexR
        super.addView(aView, in: gravity)
        addInsetL = -1
        addInsetR = -1
        flexibleRight = false
    }
    
    override func addView(_ aView: NSView, in gravity: NSStackViewGravity) {
        addView(aView, inGravity: gravity, inset: defaultInset)
    }
    
    func insertView(_ aView: NSView, atIndex index: Int, inGravity gravity: NSStackViewGravity, inset: CGFloat) {
        super.insertView(aView, at: index, in: gravity)
        
        let useInsetL = addInsetL != -1 ? addInsetL : inset
        let useInsetR = addInsetR != -1 ? addInsetR : inset
        let rightSide = flexibleRight ? ">=" : ""
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(useInsetL))-[newView]-(\(rightSide)\(useInsetR))-|", options: [], metrics: nil, views: ["newView": aView]))
    }
    
    override func insertView(_ aView: NSView, at index: Int, in gravity: NSStackViewGravity) {
        insertView(aView, atIndex: index, inGravity: gravity, inset: defaultInset)
    }
    
    func removeAllViews() {
        for view in views {
            removeView(view)
        }
    }
    
}
