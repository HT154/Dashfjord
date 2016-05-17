//
//  VideoThumbnailView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/29/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class VideoThumbnailView: NSView {
    
    private var imageView: NSImageView = {
        let imageView = NSImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.imageScaling = .ScaleProportionallyUpOrDown
        
        return imageView
    }()
    
    private var playButton: NSButton = {
        let button = NSButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.image = NSImage(named: "play")
        button.imagePosition = .ImageOnly
        button.action = #selector(VideoThumbnailView.permalinkButton(_:))
        button.bordered = false
        (button.cell! as! NSButtonCell).imageScaling = .ScaleProportionallyUpOrDown
        (button.cell! as! NSButtonCell).setButtonType(NSButtonType.MomentaryChangeButton)
        NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 100).active = true
        NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 100).active = true
        
        let shadow = NSShadow()
        shadow.shadowOffset = NSSize(width: 2, height: 2)
        
        button.shadow = shadow
        
        return button
    }()
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    init() {
        super.init(frame: NSZeroRect)
        
        addSubview(imageView)
        addSubview(playButton)
        
        playButton.target = self
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[imageView]-0-|", options: [], metrics: nil, views: ["imageView": imageView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[imageView]-0-|", options: [], metrics: nil, views: ["imageView": imageView]))
        
        NSLayoutConstraint(item: playButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: playButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0).active = true
    }
    
    var thumbnailURL: String? {
        didSet {
            if let url = thumbnailURL {
                PhotoCache.sharedInstance.loadURL(url, into: imageView)
            } else {
                imageView.image = nil
            }
        }
    }
    
    var permalinkURL: String?
    
    @IBAction func permalinkButton(sender: AnyObject!) {
        guard let stringURL = permalinkURL else { return }
        guard let url = NSURL(string: stringURL) else { return }
        
        NSWorkspace.sharedWorkspace().openURL(url)
    }
    
}
