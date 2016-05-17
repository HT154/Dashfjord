//
//  Trail.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/20/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class Trail: NSObject, ModelType {

    var blog: Blog
    var content: String = ""
    var postID: Int
    var rootItem = false
    var currentItem = false
    
    required init(dict: JSONDict) {
        blog = Blog(dict: dict["blog"]! as! [String : AnyObject])

        var preContent: String
        
        if let c = dict["content_raw"] as? String {
            preContent = c
        } else if let c = dict["content"] as? String {
            preContent = c
        } else {
            preContent = ""
        }
        
        while let preStart = preContent.rangeOfString("<pre>") {
            guard let preEnd = preContent.rangeOfString("</pre>") else { break }
            
            content += preContent.substringToIndex(preStart.startIndex).stringByReplacingOccurrencesOfString("\n", withString: " ")
            content += preContent.substringWithRange(preStart.startIndex..<preEnd.endIndex)
            
            preContent = preContent.substringFromIndex(preEnd.endIndex)
        }
        
        content += preContent.stringByReplacingOccurrencesOfString("\n", withString: " ")
        
        if dict["post"]!["id"]! is Int {
            postID = dict["post"]!["id"]! as! Int
        } else {
            postID = Int(dict["post"]!["id"]! as! String)!
        }
        
        if let isRoot = dict["is_root_item"] as! Bool? {
            rootItem = isRoot
        }
        
        if let isCurrent = dict["is_current_item"] as! Bool? {
            currentItem = isCurrent
        }
    }
    
}
