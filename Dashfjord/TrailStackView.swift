//
//  TrailStackView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/24/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class TrailStackView: WidthStretchingStackView {
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    override init() {
        super.init()
        spacing = 0
    }
    
    func addTrail(trails: [Trail], includeFirstHorizontalLine: Bool = true, includeFirstTrailHeader: Bool = true) {
        for (i, trail) in trails.enumerate() {
            if i != 0 || includeFirstHorizontalLine {
                addView(HorizontalLineView(), inGravity: .Center)
            }
            
            if i == 0 && !includeFirstTrailHeader {
                let view = TrailContentView()
                view.parseString(trail.content)
                
                addView(view, inGravity: .Center)
            } else {
                let view = TrailView()
                view.trail = trail
                
                addView(view, inGravity: .Center)
            }
        }
    }
    
}
