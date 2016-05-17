//
//  TintButton.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/24/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

@IBDesignable class ImageTintButton: NSButton {
    
    @IBInspectable var inactiveTint: NSColor = NSColor(calibratedWhite: (160.0/255), alpha: 1.0) {
        didSet { reloadImage() }
    }
    
    @IBInspectable var activeTint: NSColor = NSColor.blackColor() {
        didSet { reloadImage() }
    }
    
    var tintActive = false {
        didSet { reloadImage() }
    }
    
    override var image: NSImage? {
        set {
            super.image = newValue
            templateImage = newValue
        }
        get {
            return super.image
        }
    }
    
    override func awakeFromNib() {
        templateImage = image
    }
    
    var templateImage: NSImage? {
        didSet {
            reloadImage()
        }
    }
    
    func reloadImage() {
        guard let tinted = templateImage?.copy() as? NSImage else { return }
        
        tinted.lockFocus()
        (tintActive ? activeTint : inactiveTint).set()
        
        let imageRect = NSRect(origin: NSZeroPoint, size: templateImage!.size)
        NSRectFillUsingOperation(imageRect, NSCompositingOperation.CompositeSourceAtop)
        
        tinted.unlockFocus()
        
        super.image = tinted
    }
    
}
