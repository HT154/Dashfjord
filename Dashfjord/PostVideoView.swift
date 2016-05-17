//
//  PostVideoView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/29/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostVideoViewController: PostContentViewController {

    let stackView = TrailStackView()
    var videoView: NSView?
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    required init() {
        super.init()
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
    }
    
    override func configureView() {
        stackView.removeAllViews()
        
        let playerButton = VideoThumbnailView()
        playerButton.thumbnailURL = post.thumbnailURL
        playerButton.permalinkURL = post.permalinkURL ?? post.postURL
        videoView = playerButton
        
        let mult = CGFloat(max(1, post.thumbnailWidth!)) / CGFloat(max(1, post.thumbnailHeight!))
        
        stackView.addView(videoView!, inGravity: .Center)
        NSLayoutConstraint(item: videoView!, attribute: .Width, relatedBy: .Equal, toItem: videoView!, attribute: .Height, multiplier: mult, constant: 0).active = true
        
        stackView.addTrail(post.trail, includeFirstHorizontalLine: false)
    }
    
}
