//
//  PostsWindowController.swift
//  Dashfjord
//
//  Created by Joshua Basch on 12/17/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostsWindowController: NSWindowController, NSWindowDelegate {

    static let ActiveChanged = "PostsWindowControllerActiveChanged"
    
    var windowIdentifier: String {
        get { return "genericPostsWindow" }
    }
    
    var preserveWindowFrame: Bool {
        get { return false }
    }
    
    var windowActive: Bool = false {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(PostsWindowController.ActiveChanged, object: self, userInfo: ["active": windowActive])
        }
    }
    
    func windowDidBecomeMain(notification: NSNotification) {
        windowActive = true
        
        if let responder = (window?.contentViewController as? PostTableViewController)?.tableView {
            window?.makeFirstResponder(responder)
        }
    }
    
    func windowDidResignMain(notification: NSNotification) {
        windowActive = false
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let fieldEditor = window?.fieldEditor(true, forObject: nil) as? NSTextView {
            fieldEditor.linkTextAttributes?[NSForegroundColorAttributeName] = Utils.bodyTextColor
        }
    }
    
    override func showWindow(sender: AnyObject?) {
        defer { super.showWindow(sender) }
        
        if preserveWindowFrame {
            guard let window = window else { return }
            
            if let frameString = NSUserDefaults.standardUserDefaults().stringForKey("\(windowIdentifier)Frame") {
                window.setFrame(NSRectFromString(frameString), display: true)
            } else {
                if let screen = window.screen {
                    window.setFrame(NSMakeRect(screen.frame.size.width - window.frame.size.width, 0, window.frame.size.width, screen.frame.size.height), display: true)
                }
            }
        }
    }
    
    func windowWillClose(notification: NSNotification) {
        if preserveWindowFrame {
            guard let window = window else { return }
            NSUserDefaults.standardUserDefaults().setObject(NSStringFromRect(window.frame), forKey: "\(windowIdentifier)Frame")
        }
    }

}
