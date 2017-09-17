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
        imageView.imageScaling = .scaleProportionallyUpOrDown
        
        return imageView
    }()
    
    private var playButton: NSButton = {
        let button = NSButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.image = NSImage(named: "play")
        button.imagePosition = .imageOnly
        button.action = #selector(VideoThumbnailView.permalinkButton(_:))
        button.isBordered = false
        (button.cell! as! NSButtonCell).imageScaling = .scaleProportionallyUpOrDown
        (button.cell! as! NSButtonCell).setButtonType(.momentaryChange)
        NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        
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
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[imageView]-0-|", options: [], metrics: nil, views: ["imageView": imageView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[imageView]-0-|", options: [], metrics: nil, views: ["imageView": imageView]))
        
        NSLayoutConstraint(item: playButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: playButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
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
    
    @IBAction func permalinkButton(_ sender: AnyObject!) {
        guard let stringURL = permalinkURL else { return }
        guard let url = URL(string: stringURL) else { return }
        
        NSWorkspace.shared().open(url)
    }
    
}
