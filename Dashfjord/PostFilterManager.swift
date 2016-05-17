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
    
    var keywords: [String] = (NSUserDefaults.standardUserDefaults().arrayForKey("filterKeywords") as? [String])?.sort() ?? [] {
        didSet { NSUserDefaults.standardUserDefaults().setObject(keywords, forKey: "filterKeywords") }
    }
    
    func shouldFilter(post: Post) -> Bool {
        let nkeywords = keywords.map { $0.lowercaseString }
        let ntags = post.tags.map { $0.lowercaseString }
        
        for keyword in nkeywords {
            if ntags.contains(keyword) || post.content.containsString(keyword) {
                return true
            }
        }
        
        return false
    }
    
}
