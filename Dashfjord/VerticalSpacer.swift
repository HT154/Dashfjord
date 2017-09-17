//
//  VerticalSpacer.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/26/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class VerticalSpacer: NSView {
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    init(height: CGFloat) {
        super.init(frame: NSZeroRect)
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height).isActive = true
    }
    
}
