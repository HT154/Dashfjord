//
//  PassThroughImageView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 11/27/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PassThroughImageView: NSImageView {

    override var mouseDownCanMoveWindow: Bool {
        return true
    }
    
}
