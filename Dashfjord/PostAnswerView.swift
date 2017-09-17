//
//  PostAnswerView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/1/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostAnswerViewController: PostContentViewController {

    let stackView = TrailStackView()
    var questionView: QuestionView!
    let topLine = HorizontalLineView()
    let topSpacer = VerticalSpacer(height: 10)
    let middleSpacer = VerticalSpacer(height: 4)
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    required init() {
        super.init()
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
    }
    
    override func configureView() {
        questionView = QuestionView()
        
        stackView.removeAllViews()
        
        stackView.addView(topLine, in: .center)
        stackView.addView(topSpacer, in: .center)
        
        questionView.question = post.question
        questionView.askingName = post.askingName
        questionView.askingURL = post.askingURL
        stackView.addView(questionView, inGravity: .center, inset: 20)
        stackView.addView(middleSpacer, in: .center)
        
        stackView.addTrail(post.trail, includeFirstHorizontalLine: false)
    }
    
}
