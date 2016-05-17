//
//  TrailHeaderView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/25/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class TrailHeaderView: NSView {

    var avatarButton = Utils.createImageButton()
    var nameButton = Utils.createTextButton()
    var actionView = ActionView()
    
    var trail: Trail! {
        didSet {
            if trail != nil {
                configureView()
            }
        }
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    init() {
        super.init(frame: NSZeroRect)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        nameButton.bold = true
        nameButton.color = NSColor.blackColor()
        actionView.setType(.Reblog)
        
        nameButton.target = self
        nameButton.action = #selector(TrailHeaderView.clickBlogButton(_:))
        avatarButton.target = self
        avatarButton.action = #selector(TrailHeaderView.clickBlogButton(_:))
        
        addSubview(avatarButton)
        addSubview(nameButton)
        addSubview(actionView)
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[avatarButton(24)]-8-[nameButton]", options: [], metrics: nil, views: ["avatarButton": avatarButton, "nameButton": nameButton]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[avatarButton(24)]-3-|", options: [], metrics: nil, views: ["avatarButton": avatarButton]))
        NSLayoutConstraint(item: nameButton, attribute: .CenterY, relatedBy: .Equal, toItem: avatarButton, attribute: .CenterY, multiplier: 1.0, constant: 0.0).active = true
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-13-[actionView(14)]", options: [], metrics: nil, views: ["actionView": actionView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-23-[actionView(14)]", options: [], metrics: nil, views: ["actionView": actionView]))
    }
    
    func configureView() {
        actionView.hidden = trail.rootItem
        nameButton.title = trail.blog.name
        AvatarCache.sharedInstance.loadAvatar(trail.blog.name, size: 48, into: avatarButton)
    }
    
    @IBAction func clickBlogButton(sender: AnyObject!) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://\(trail.blog.name).tumblr.com/post/\(trail.postID)")!)
    }
    
}
