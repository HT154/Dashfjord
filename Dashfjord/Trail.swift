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
        
        while let preStart = preContent.range(of: "<pre>") {
            guard let preEnd = preContent.range(of: "</pre>") else { break }
            
            content += preContent.substring(to: preStart.lowerBound).replacingOccurrences(of: "\n", with: " ")
            content += preContent.substring(with: preStart.lowerBound..<preEnd.upperBound)
            
            preContent = preContent.substring(from: preEnd.upperBound)
        }
        
        content += preContent.replacingOccurrences(of: "\n", with: " ")
        
        if (dict["post"] as! JSONDict)["id"]! is Int {
            postID = (dict["post"] as! JSONDict)["id"]! as! Int
        } else {
            postID = Int((dict["post"] as! JSONDict)["id"]! as! String)!
        }
        
        if let isRoot = dict["is_root_item"] as! Bool? {
            rootItem = isRoot
        }
        
        if let isCurrent = dict["is_current_item"] as! Bool? {
            currentItem = isCurrent
        }
    }
    
}
