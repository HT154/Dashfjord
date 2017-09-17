//
//  TrimScaleImageButtonCell.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/27/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class TrimScaleImageButtonCell: NSCell {

    override func startTracking(at startPoint: NSPoint, in controlView: NSView) -> Bool {
        (controlView as! TrimScaleImageButton).showShadeView = true
        return true
    }
    
    override func stopTracking(last lastPoint: NSPoint, current stopPoint: NSPoint, in controlView: NSView, mouseIsUp flag: Bool) {
        (controlView as! TrimScaleImageButton).showShadeView = false
        
        if flag {
            (controlView as! TrimScaleImageButton).sendAction()
        }
    }
    
    override func continueTracking(last lastPoint: NSPoint, current currentPoint: NSPoint, in controlView: NSView) -> Bool {
        return true
    }
    
}
