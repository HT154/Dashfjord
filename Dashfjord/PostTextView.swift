//
//  PostTextView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/21/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostTextViewController: PostContentViewController {
    
    let stackView = TrailStackView()
    let topLine = HorizontalLineView()
    let preTitleSpacer = VerticalSpacer(height: 10)
    let postTitleSpacer = VerticalSpacer(height: 10)
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    required init() {
        super.init()
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
    }
    
    override func configureView() {
        stackView.removeAllViews()
        
        var titleHidden = true
        let hideTopLine = post.trail.count == 1 && post.trail[0].currentItem
        
        if let title = post.title {
            if title != "" {
                stackView.addView(topLine, in: .center)
                
                if !hideTopLine {
                    let trailHeader = TrailHeaderView()
                    
                    if post.trail.count > 0 {
                        trailHeader.trail = post.trail[0]
                    } else {
                        let trail = Trail(dict: ["blog": ["name": post.rebloggedRootName ?? post.blogName], "post": ["id": post.id], "is_root_item": true, "is_current_item": true])
                        
                        trailHeader.trail = trail
                    }
                    
                    stackView.addView(trailHeader, inGravity: .center, inset: 20)
                }
                
                stackView.addView(preTitleSpacer, in: .center)
                
                preTitleSpacer.isHidden = hideTopLine
                topLine.isHidden = hideTopLine
                
                let titleLabel = Utils.createResizingLabel()
                titleLabel.textColor = Utils.bodyTextColor
                titleLabel.font = Font.get(.Title, size: 32)
                titleLabel.stringValue = title
                
                stackView.addView(titleLabel, inGravity: .center, inset: 20)
                stackView.addView(postTitleSpacer, in: .center)
                
                titleHidden = false
            }
        }
        
        stackView.addTrail(post.trail, includeFirstHorizontalLine: titleHidden && !hideTopLine, includeFirstTrailHeader: titleHidden || hideTopLine)
    }
    
}
