//
//  PostContentView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/21/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostContentViewController: NSViewController {
    
    var post: Post! {
        didSet {
            if post != nil {
                configureView()
            }
        }
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    required init() {
        super.init(nibName: nil, bundle: nil)!
        
        view = NSView()
        view.setContentCompressionResistancePriority(NSLayoutPriorityRequired, for: .vertical)
        view.setContentHuggingPriority(NSLayoutPriorityRequired, for: .vertical)
    }
    
    func configureView() {
        
    }
    
    func destroyView() {
    
    }
    
}
