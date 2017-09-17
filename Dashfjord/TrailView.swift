//
//  TrailView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/25/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class TrailView: NSView {
    
    var headerView = TrailHeaderView()
    var stackView = TrailContentView()
    
    var trail: Trail! {
        didSet{
            if trail != nil {
                configureView()
            }
        }
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    init() {
        super.init(frame: NSZeroRect)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
    }
    
    func configureView() {
        stackView.removeAllViews()
        
        stackView.addView(headerView, inGravity: .center, inset: 20)
        
        headerView.isHidden = trail.currentItem && trail.rootItem
        headerView.trail = trail
        
        stackView.parseString(trail.content)
    }
    
}
