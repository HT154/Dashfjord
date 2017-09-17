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
    
    private var linkURL: URL?
    
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
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        aspectConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 1, constant: 0)
        aspectConstraint.isActive = true
        
        addSubview(imageView)
        
        centerXConstraint = NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        centerYConstraint = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
        
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[imageView]-0-|", options: [], metrics: nil, views: ["imageView": imageView])
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[imageView]-0-|", options: [], metrics: nil, views: ["imageView": imageView])
        NSLayoutConstraint.activate(horizontalConstraints)
        
        wConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1)
        wConstraint.priority = NSLayoutPriorityDefaultHigh - 1
        aConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
        
        shadeView.translatesAutoresizingMaskIntoConstraints = false
        shadeView.color = NSColor(calibratedWhite: 0, alpha: 0.5)
        shadeView.isHidden = true
        
        addSubview(shadeView)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[shadeView]-0-|", options: [], metrics: nil, views: ["shadeView": shadeView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[shadeView]-0-|", options: [], metrics: nil, views: ["shadeView": shadeView]))
    }
    
    var image: NSImage? {
        set {
            imageView.image = newValue
            setNeedsDisplay(bounds)
            
            if let img = image {
                let viewAspect = bounds.size.width / bounds.size.height
                let imageAspect = img.size.width / img.size.height
                
                aspectConstraint.isActive = false
                aspectConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: imageAspect, constant: 0)
                aspectConstraint.isActive = true
                
                if autoAspect {
                    NSLayoutConstraint.activate(verticalConstraints)
                    NSLayoutConstraint.activate(horizontalConstraints)
                } else if viewAspect < imageAspect {
                    NSLayoutConstraint.deactivate(horizontalConstraints)
                    NSLayoutConstraint.activate(verticalConstraints)
                } else {
                    NSLayoutConstraint.deactivate(verticalConstraints)
                    NSLayoutConstraint.activate(horizontalConstraints)
                }
                
                if autoWidth {
                    wConstraint.constant = img.size.width
                    wConstraint.isActive = true
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
    
    func notifyLayoutChange(_ view: NSView?) {
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
                shadeView.isHidden = !showShadeView
            }
        }
    }
    
    func sendAction() {
        sendAction(action, to: target)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if image == nil {
            NSColor(calibratedWhite: 0.9, alpha: 1.0).set()
            NSBezierPath(rect: bounds).fill()
        }
    }
    
    func setLink(_ link: URL?) {
        linkURL = link
        
        if linkURL != nil {
            target = self
            action = #selector(TrimScaleImageButton.openLink(_:))
        } else {
            target = nil
        }
    }
    
    @IBAction func openLink(_ sender: AnyObject!) {
        NSWorkspace.shared().open(linkURL!)
    }
    
}
