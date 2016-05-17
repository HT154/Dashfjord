//
//  PostContentViewReuseManager.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/22/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostContentViewReuseManager: NSObject {
    
    static let sharedInstance = PostContentViewReuseManager()
    
    private var types: [PostType:(viewClass: PostContentViewController.Type, views: [PostContentViewController])] = [
        .Text: (PostTextViewController.self, []),
        .Photo: (PostPhotoViewController.self, []),
        .Quote: (PostQuoteViewController.self, []),
        .Link: (PostLinkViewController.self, []),
        .Chat: (PostChatViewController.self, []),
        .Audio: (PostAudioViewController.self, []),
        .Video: (PostVideoViewController.self, []),
        .Answer: (PostAnswerViewController.self, []),
    ]
    
    func viewControllerRetiredForType(type: PostType, view: PostContentViewController) {
        types[type]!.views.append(view)
    }
    
    func viewControllerForType(type: PostType) -> PostContentViewController {
        if types[type]!.views.count > 0 {
            let retViewController = types[type]!.views.first!
            types[type]!.views.removeAtIndex(0)
            retViewController.view.prepareForReuse()
            
            return retViewController
        }
        
        return makeViewWithType(type)
    }
    
    private func makeViewWithType<T: PostContentViewController>(type: PostType) -> T! {
        return (types[type]!.viewClass as PostContentViewController.Type).init() as! T
    }
    
}
