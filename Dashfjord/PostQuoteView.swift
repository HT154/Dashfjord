//
//  PostQuoteView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/29/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostQuoteViewController: PostContentViewController {

    let stackView = WidthStretchingStackView()
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    required init() {
        super.init()
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
    }
    
    override func configureView() {
        stackView.removeAllViews()
        
        var quoteFontSize: CGFloat = 16
        switch post.text!.characters.count {
        case 0...19: quoteFontSize = 48
        case 20...80: quoteFontSize = 36
        case 81...300: quoteFontSize = 24
        default: break
        }
        
        let quoteLabel = Utils.createResizingLabel()
        quoteLabel.textColor = Utils.quoteTextColor
        quoteLabel.font = Font.get(.Serif, size: quoteFontSize)
        
        quoteLabel.stringValue = "“\(post.text?.withoutHTMLEntities() ?? "")”"
        
        stackView.addView(quoteLabel, inGravity: .Center, inset: 20)
        
        if post.source!.characters.count > 0 {
            let sourceView = TrailContentView()
            sourceView.parseString(post.source!)
            stackView.addView(sourceView, inGravity: .Center, inset: 0)
        }
    }
    
}
