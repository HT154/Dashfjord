//
//  PostAudioView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/5/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostAudioViewController: PostContentViewController {

    let stackView = TrailStackView()
    var audioView: AudioPlayerView?
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    required init() {
        super.init()
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
    }
    
    override func configureView() {
        stackView.removeAllViews()
        
        audioView = AudioPlayerView()
        audioView!.post = post
        stackView.addView(audioView!, in: .center)
        
        stackView.addTrail(post.trail, includeFirstHorizontalLine: false)
    }
    
}
