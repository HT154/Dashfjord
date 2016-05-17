//
//  TrimScaleImageButton.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/27/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class TrimScaleImageButton: NSControl {
    
    var imageView: NSImageView!
    
    private var horizontalConstraints: [NSLayoutConstraint]!
    private var verticalConstraints: [NSLayoutConstraint]!
    private var centerXConstraint: NSLayoutConstraint!
    private var centerYConstraint: NSLayoutConstraint!
    private var aspectConstraint: NSLayoutConstraint!
    
    private var wConstraint: NSLayoutConstraint!
    private var aConstraint: NSLayoutConstraint!
    
    private var shadeView = ColorView()
    
    private var autoAspect = false
    private var autoWidth = false
    
    private var linkURL: NSURL?
    
    override class func cellClass() -> AnyClass? {
        return TrimScaleImageButtonCell.self
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    init(autosizeAspect: Bool = false, autosizeWidth: Bool = false) {
        super.init(frame: NSZeroRect)
        
        autoAspect = autosizeAspect
        autoWidth = autosizeWidth
        translatesAutoresizingMaskIntoConstraints = false
        
        imageView = NSImageView()
        imageView.animates = true
        imageView.imageScaling = .ScaleProportionallyUpOrDown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        aspectConstraint = NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: 1, constant: 0)
        aspectConstraint.active = true
        
        addSubview(imageView)
        
        centerXConstraint = NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
        centerYConstraint = NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activateConstraints([centerXConstraint, centerYConstraint])
        
        horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[imageView]-0-|", options: [], metrics: nil, views: ["imageView": imageView])
        verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[imageView]-0-|", options: [], metrics: nil, views: ["imageView": imageView])
        NSLayoutConstraint.activateConstraints(horizontalConstraints)
        
        wConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 1)
        wConstraint.priority = NSLayoutPriorityDefaultHigh - 1
        aConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0)
        
        shadeView.translatesAutoresizingMaskIntoConstraints = false
        shadeView.color = NSColor(calibratedWhite: 0, alpha: 0.5)
        shadeView.hidden = true
        
        addSubview(shadeView)
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[shadeView]-0-|", options: [], metrics: nil, views: ["shadeView": shadeView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[shadeView]-0-|", options: [], metrics: nil, views: ["shadeView": shadeView]))
    }
    
    var image: NSImage? {
        set {
            imageView.image = newValue
            setNeedsDisplayInRect(bounds)
            
            if let img = image {
                let viewAspect = bounds.size.width / bounds.size.height
                let imageAspect = img.size.width / img.size.height
                
                aspectConstraint.active = false
                aspectConstraint = NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: imageAspect, constant: 0)
                aspectConstraint.active = true
                
                if autoAspect {
                    NSLayoutConstraint.activateConstraints(verticalConstraints)
                    NSLayoutConstraint.activateConstraints(horizontalConstraints)
                } else if viewAspect < imageAspect {
                    NSLayoutConstraint.deactivateConstraints(horizontalConstraints)
                    NSLayoutConstraint.activateConstraints(verticalConstraints)
                } else {
                    NSLayoutConstraint.deactivateConstraints(verticalConstraints)
                    NSLayoutConstraint.activateConstraints(horizontalConstraints)
                }
                
                if autoWidth {
                    wConstraint.constant = img.size.width
                    wConstraint.active = true
                }
            }
            
            if autoAspect {
                notifyLayoutChange()
            }
        }
        get { return imageView.image }
    }
    
    func notifyLayoutChange() {
        if let s = superview {
            notifyLayoutChange(s)
        }
    }
    
    func notifyLayoutChange(view: NSView?) {
        guard let v = view else { return }
        
        if v is PostView {
            (v as! PostView).updateHeight()
        } else {
            notifyLayoutChange(v.superview)
        }
    }
    
    var showShadeView = false {
        didSet {
            if target != nil {
                shadeView.hidden = !showShadeView
            }
        }
    }
    
    func sendAction() {
        sendAction(action, to: target)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if image == nil {
            NSColor(calibratedWhite: 0.9, alpha: 1.0).set()
            NSBezierPath(rect: bounds).fill()
        }
    }
    
    func setLink(link: NSURL?) {
        linkURL = link
        
        if linkURL != nil {
            target = self
            action = #selector(TrimScaleImageButton.openLink(_:))
        } else {
            target = nil
        }
    }
    
    @IBAction func openLink(sender: AnyObject!) {
        NSWorkspace.sharedWorkspace().openURL(linkURL!)
    }
    
}
