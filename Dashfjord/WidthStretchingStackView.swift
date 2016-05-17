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
        orientation = .Vertical
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    var addInsetL: CGFloat = -1
    var addInsetR: CGFloat = -1
    var flexibleRight = false
    
    func addView(aView: NSView, inGravity gravity: NSStackViewGravity, insetLeft: CGFloat, insetRight: CGFloat) {
        addInsetL = insetLeft
        addInsetR = insetRight
        super.addView(aView, inGravity: gravity)
        addInsetL = -1
        addInsetR = -1
    }
    
    func addView(aView: NSView, inGravity gravity: NSStackViewGravity, inset: CGFloat, flexibleRight flexR: Bool = false) {
        addInsetL = inset
        addInsetR = inset
        flexibleRight = flexR
        super.addView(aView, inGravity: gravity)
        addInsetL = -1
        addInsetR = -1
        flexibleRight = false
    }
    
    override func addView(aView: NSView, inGravity gravity: NSStackViewGravity) {
        addView(aView, inGravity: gravity, inset: defaultInset)
    }
    
    func insertView(aView: NSView, atIndex index: Int, inGravity gravity: NSStackViewGravity, inset: CGFloat) {
        super.insertView(aView, atIndex: index, inGravity: gravity)
        
        let useInsetL = addInsetL != -1 ? addInsetL : inset
        let useInsetR = addInsetR != -1 ? addInsetR : inset
        let rightSide = flexibleRight ? ">=" : ""
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(\(useInsetL))-[newView]-(\(rightSide)\(useInsetR))-|", options: [], metrics: nil, views: ["newView": aView]))
    }
    
    override func insertView(aView: NSView, atIndex index: Int, inGravity gravity: NSStackViewGravity) {
        insertView(aView, atIndex: index, inGravity: gravity, inset: defaultInset)
    }
    
    func removeAllViews() {
        for view in views {
            removeView(view)
        }
    }
    
}
