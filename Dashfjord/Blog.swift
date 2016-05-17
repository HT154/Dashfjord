//
//  Blog.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/20/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class Blog: NSObject, ModelType {
    
    var active = true
    var admin = false
    var ask = false
    var askAnon = false
    var askPageTitle: String?
    var canSendFanmail = false
    var description_: String?
    var drafts: Int?
    var followed = false
    var followers: Int?
    var isBlockedFromPrimary = false
    var isNSFW = false
    var messages: Int?
    var name: String
    var posts: Int?
    var primary = false
    var queue: Int?
    var shareLikes = false
    var title: String = ""
    var theme: Theme?
    var type: String?
    var updated: NSDate?
    var URL: String?
    
    required init(dict: JSONDict) {
        if let b = dict["active"] as? Bool {
            active = b
        }
        
        if let b = dict["admin"] as? Bool {
            admin = b
        }
        
        if let b = dict["ask"] as? Bool {
            ask = b
        }
        
        if let b = dict["ask_anon"] as? Bool {
            askAnon = b
        }
        
        if let s = dict["ask_page_title"] as? String {
            askPageTitle = s
        }
        
        if let b = dict["can_send_fanmail"] as? Bool {
            canSendFanmail = b
        }
        
        if let s = dict["description"] as? String {
            description_ = s
        }
        
        if let i = dict["drafts"] as? Int {
            drafts = i
        }
        
        if let b = dict["followed"] as? Bool {
            followed = b
        }
        
        if let i = dict["followers"] as? Int {
            followers = i
        }
        
        if let b = dict["is_blocked_from_primary"] as? Bool {
            isBlockedFromPrimary = b
        }
        
        if let b = dict["is_nsfw"] as? Bool {
            isNSFW = b
        }
        
        if let i = dict["messages"] as? Int {
            messages = i
        }
        
        name = dict["name"] as! String
        
        if let i = dict["posts"] as? Int {
            posts = i
        }
        
        if let b = dict["primary"] as? Bool {
            primary = b
        }
        
        if let i = dict["queue"] as? Int {
            queue = i
        }
        
        if let b = dict["share_likes"] as? Bool {
            shareLikes = b
        }
        
        if let tit = dict["title"] as? String {
            title = tit
        }
        
        if dict["theme"] != nil && dict["theme"] is NSDictionary {
            theme = Theme(dict: dict["theme"]! as! [String : AnyObject])
        }
        
        if let s = dict["type"] as? String {
            type = s
        }
        
        if let timestamp = dict["updated"] as? NSTimeInterval {
            updated = NSDate(timeIntervalSince1970: timestamp)
        }
        
        if let s = dict["url"] as? String {
            URL = s
        }
    }
    
}
