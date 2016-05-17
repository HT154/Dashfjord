//
//  DashboardWindowController.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/3/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class DashboardWindowController: PostsWindowController {
    
    @IBOutlet var titleBarView: ColorView!
    @IBOutlet var composeView: NSView!
    @IBOutlet var newPostsBadge: NSView!
    @IBOutlet var newPostsLabel: NSTextField!
    @IBOutlet var avatarImageButton: NSButton!
    @IBOutlet var composeButton: NSButton!
    
    lazy var blogsViewController: BlogsViewController = { return self.storyboard?.instantiateControllerWithIdentifier("blogsViewController") as! BlogsViewController }()
    
    override var windowIdentifier: String {
        get { return "dashboardWindow" }
    }
    
    override var preserveWindowFrame: Bool {
        get { return true }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        titleBarView.translatesAutoresizingMaskIntoConstraints = false
        let win  = (window! as! WAYWindow)
        
        win.titleBarHeight = 48
        
        win.titleBarView.addSubview(titleBarView, positioned: .Below, relativeTo: nil)
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": titleBarView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": titleBarView]))
        
        win.trafficLightButtonsLeftMargin = 16
        
        NSNotificationCenter.defaultCenter().addObserverForName(BlogManager.CurrentBlogChanged, object: nil, queue: nil) { (notification: NSNotification) in
            let blog = notification.object as! Blog
            AvatarCache.sharedInstance.loadAvatar(blog.name, size: 64, into: self.avatarImageButton)
        }
    }
    
    override var windowActive: Bool {
        didSet {
            titleBarView.showAlternate = !windowActive
            newPostsLabel.textColor = windowActive ? titleBarView.color : titleBarView.alternateColor
            (window?.contentView as? ColorView)?.showAlternate = !windowActive
        }
    }
    
    func setPostsBadge(string: String?) {
        if let str = string {
            newPostsLabel.stringValue = str
            newPostsBadge.hidden = false
        } else {
            newPostsBadge.hidden = true
        }
    }
    
    lazy var composePopover: NSPopover = {
        let vc = NSViewController()
        vc.view = self.composeView
        
        let popover = NSPopover()
        popover.behavior = .Transient
        popover.contentViewController = vc
        
        return popover
    }()
    
    @IBAction func composeButton(sender: NSButton!) {
        composePopover.showRelativeToRect(composeButton.bounds, ofView: composeButton, preferredEdge: .MaxY)
    }
    
    static let taggedTypes: [PostType] = [.Text, .Photo, .Quote, .Link, .Chat, .Audio, .Video]
    @IBAction func newPostButton(sender: NSButton!) {
        let blogSelect: String
        if let b = BlogManager.sharedInstance.currentBlogName {
            blogSelect = "/blog/\(b)"
        } else {
            blogSelect = ""
        }
        
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://tumblr.com\(blogSelect)/new/\(DashboardWindowController.taggedTypes[sender.tag].rawValue)")!)
    }
    
    lazy var userPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Transient
        popover.contentViewController = self.blogsViewController
        
        self.blogsViewController.popover = popover
        
        return popover
    }()
    
    @IBAction func userButton(sender: NSButton!) {
        userPopover.contentSize = NSSize(width: blogsViewController.view.bounds.size.width, height: min(window!.frame.size.height - 100, blogsViewController.tableView.rowHeight * CGFloat(BlogManager.sharedInstance.blogs.count)))
        
        userPopover.showRelativeToRect(sender.bounds, ofView: sender, preferredEdge: .MaxY)
    }
    
    @IBAction func homeButton(sender: AnyObject!) {
        (window?.contentViewController?.childViewControllers[0] as? PostTableViewController)?.homeButton(sender)
    }
    
}
