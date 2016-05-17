//
//  Note.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/20/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

enum NoteType: String {
    case Like = "like"
    case Reblog = "reblog"
    case Reply = "reply"
    case Answer = "answer"
    case Posted = "posted"
    case Follow = "follow"
}

class Note: NSObject, ModelType {
    
    var blogName: String
    var blogURL: String
    var timestamp: Int
    var type: NoteType
    var pastTenseVerb: String {
        get {
            switch type {
            case .Like: return "liked"
            case .Reblog: return "reblogged"
            case .Reply: return "replied to"
            case .Answer: return "answered"
            case .Posted: return "posted"
            case .Follow: return "followed"
            }
        }
    }
    
    var text: String?
    
    required init(dict: JSONDict) {
        blogName = dict["blog_name"]! as! String
        blogURL = dict["blog_url"]! as! String
        
        if dict["timestamp"]! is Int {
            timestamp = dict["timestamp"]! as! Int
        } else {
            timestamp = Int(dict["timestamp"]! as! String)!
        }
        
        type = NoteType(rawValue: dict["type"]! as! String)!
        
        if let t = dict["reply_text"] as? String {
            text = t
        }
        
        if let t = dict["added_text"] as? String {
            text = t
        }
    }

}
