//
//  TrimScaleImageButtonCell.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/27/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class TrimScaleImageButtonCell: NSCell {

    override func startTrackingAt(startPoint: NSPoint, inView controlView: NSView) -> Bool {
        (controlView as! TrimScaleImageButton).showShadeView = true
        return true
    }
    
    override func stopTracking(lastPoint: NSPoint, at stopPoint: NSPoint, inView controlView: NSView, mouseIsUp flag: Bool) {
        (controlView as! TrimScaleImageButton).showShadeView = false
        
        if flag {
            (controlView as! TrimScaleImageButton).sendAction()
        }
    }
    
    override func continueTracking(lastPoint: NSPoint, at currentPoint: NSPoint, inView controlView: NSView) -> Bool {
        return true
    }
    
}
