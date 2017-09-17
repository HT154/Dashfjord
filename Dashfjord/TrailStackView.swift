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
    
    func addTrail(_ trails: [Trail], includeFirstHorizontalLine: Bool = true, includeFirstTrailHeader: Bool = true) {
        for (i, trail) in trails.enumerated() {
            if i != 0 || includeFirstHorizontalLine {
                addView(HorizontalLineView(), in: .center)
            }
            
            if i == 0 && !includeFirstTrailHeader {
                let view = TrailContentView()
                view.parseString(trail.content)
                
                addView(view, in: .center)
            } else {
                let view = TrailView()
                view.trail = trail
                
                addView(view, in: .center)
            }
        }
    }
    
}
