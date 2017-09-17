//
//  PostChatView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/29/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostChatViewController: PostContentViewController {

    let stackView = WidthStretchingStackView()
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    required init() {
        super.init()
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
    }
    
    override func configureView() {
        stackView.removeAllViews()
        
        if let title = post.title {
            if title != "" {
                let titleLabel = Utils.createResizingLabel()
                titleLabel.alignment = .left
                titleLabel.font = Font.get(size: 32)
                titleLabel.stringValue = title
                
                stackView.addView(titleLabel, inGravity: .center, inset: 20)
            }
        }
        
        for chatLine in post.dialogue! {
            let chatLineView = Utils.createResizingLabel()
            chatLineView.alignment = .left
            
            let name = chatLine["name"]!.replacingOccurrences(of: "<[^>]*>", with: "", options: [.regularExpression], range: nil)
            let phrase = chatLine["phrase"]!.replacingOccurrences(of: "<[^>]*>", with: "", options: [.regularExpression], range: nil)
            let line: String
            
            if name != "" {
                line = "\(name): \(phrase)"
            } else {
                line = phrase
            }
            
            let chatLineString = NSMutableAttributedString(string: line, attributes: [NSFontAttributeName: Font.get(.Monospace, size: 14)])
            
            if name != "" {
                chatLineString.addAttribute(NSFontAttributeName, value: Font.get(.Monospace, weight: .Bold, size: 14), range: NSMakeRange(0, name.characters.count + 1))
            }
            
            chatLineView.attributedStringValue = chatLineString
            
            stackView.addView(chatLineView, inGravity: .center, inset: 20)
        }
    }
    
}
