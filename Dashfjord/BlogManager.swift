//
//  BlogManager.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/4/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class BlogManager {
    
    static let BlogsLoaded = "BlogManagerBlogsLoaded"
    static let CurrentBlogChanged = "BlogManagerCurrentBlogChanged"
    
    static let sharedInstance = BlogManager()
    
    var blogs: [Blog] = []
    
    init() {
        NSNotificationCenter.defaultCenter().addObserverForName(ReachabilityChangedNotification, object: nil, queue: nil) { (note: NSNotification) -> Void in
            let reachability = note.object as! Reachability
            
            if reachability.isReachable() && self.blogs.count == 0 {
                self.refresh()
            }
        }
    }
    
    var currentBlogName: String? = NSUserDefaults.standardUserDefaults().stringForKey("currentBlogName") {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(currentBlogName, forKey: "currentBlogName")
            NSNotificationCenter.defaultCenter().postNotificationName(BlogManager.CurrentBlogChanged, object: blogNamed(currentBlogName))
        }
    }
    
    var currentBlog: Blog? {
        return blogNamed(currentBlogName)
    }
    
    func refresh() {
        API.info { info, blogs, error in
            guard let blogs = blogs else { return }
            self.blogs = blogs
            
            NSNotificationCenter.defaultCenter().postNotificationName(BlogManager.BlogsLoaded, object: self.blogs)
            
            if self.currentBlogName == nil {
                self.currentBlogName = self.blogs[0].name
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(BlogManager.CurrentBlogChanged, object: self.blogNamed(self.currentBlogName))
            }
        }
    }
    
    func blogNamed(blogName: String?) -> Blog? {
        guard let name = blogName else { return nil }
        
        for blog in blogs {
            if blog.name == name {
                return blog
            }
        }
        
        return nil
    }
    
    func isMyBlog(blogName: String) -> Bool {
        return blogNamed(blogName) != nil
    }
    
}
