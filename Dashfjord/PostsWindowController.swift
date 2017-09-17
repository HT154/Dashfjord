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
            NotificationCenter.default.post(name: Notification.Name(rawValue: PostsWindowController.ActiveChanged), object: self, userInfo: ["active": windowActive])
        }
    }
    
    func windowDidBecomeMain(_ notification: Notification) {
        windowActive = true
        
        if let responder = (window?.contentViewController as? PostTableViewController)?.tableView {
            window?.makeFirstResponder(responder)
        }
    }
    
    func windowDidResignMain(_ notification: Notification) {
        windowActive = false
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let fieldEditor = window?.fieldEditor(true, for: nil) as? NSTextView {
            fieldEditor.linkTextAttributes?[NSForegroundColorAttributeName] = Utils.bodyTextColor
        }
    }
    
    override func showWindow(_ sender: Any?) {
        defer { super.showWindow(sender) }
        
        if preserveWindowFrame {
            guard let window = window else { return }
            
            if let frameString = UserDefaults.standard.string(forKey: "\(windowIdentifier)Frame") {
                window.setFrame(NSRectFromString(frameString), display: true)
            } else {
                if let screen = window.screen {
                    window.setFrame(NSMakeRect(screen.frame.size.width - window.frame.size.width, 0, window.frame.size.width, screen.frame.size.height), display: true)
                }
            }
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        if preserveWindowFrame {
            guard let window = window else { return }
            UserDefaults.standard.set(NSStringFromRect(window.frame), forKey: "\(windowIdentifier)Frame")
        }
    }

}
