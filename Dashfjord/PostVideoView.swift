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
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
    }
    
    override func configureView() {
        stackView.removeAllViews()
        
        let playerButton = VideoThumbnailView()
        playerButton.thumbnailURL = post.thumbnailURL
        playerButton.permalinkURL = post.permalinkURL ?? post.postURL
        videoView = playerButton
        
        let mult = CGFloat(max(1, post.thumbnailWidth ?? 1)) / CGFloat(max(1, post.thumbnailHeight ?? 1))
        
        stackView.addView(videoView!, in: .center)
        NSLayoutConstraint(item: videoView!, attribute: .width, relatedBy: .equal, toItem: videoView!, attribute: .height, multiplier: mult, constant: 0).isActive = true
        
        stackView.addTrail(post.trail, includeFirstHorizontalLine: false)
    }
    
}
