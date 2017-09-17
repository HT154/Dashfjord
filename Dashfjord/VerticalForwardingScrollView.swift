//
//  VerticalForwardingScrollView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/21/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class VerticalForwardingScrollView: NSScrollView {

    var forward: Bool = true
    
    override func scrollWheel(with theEvent: NSEvent) {
        if theEvent.phase == .began  {
            forward = abs(theEvent.scrollingDeltaY) >= 1 && theEvent.scrollingDeltaX == 0
        }
        
        if theEvent.momentumPhase == .ended  {
            forward = true
        }
        
        if forward {
            enclosingScrollView?.scrollWheel(with: theEvent)
        } else {
            super.scrollWheel(with: theEvent)
        }
    }
    
}
