//
//  PostFilterManager.swift
//  Dashfjord
//
//  Created by Joshua Basch on 11/12/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostFilterManager {
    
    static let sharedInstance = PostFilterManager()
    
    var keywords: [String] = (UserDefaults.standard.array(forKey: "filterKeywords") as? [String])?.sorted() ?? [] {
        didSet { UserDefaults.standard.set(keywords, forKey: "filterKeywords") }
    }
    
    func shouldFilter(_ post: Post) -> Bool {
        let nkeywords = keywords.map { $0.lowercased() }
        let ntags = post.tags.map { $0.lowercased() }
        
        for keyword in nkeywords {
            if ntags.contains(keyword) || post.content.contains(keyword) {
                return true
            }
        }
        
        return false
    }
    
}
