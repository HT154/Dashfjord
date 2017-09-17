//
//  PostTableCellView.swift
//  Treadr
//
//  Created by Joshua Basch on 9/19/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostView: NSTableCellView, NSTextViewDelegate, NSSharingServicePickerDelegate {
    
    var controller: PostTableViewController!
    var post: Post! {
        didSet { if post != nil { configureView() } }
    }
    
    var selected = false {
        didSet {
            selectionCaret.animator().isHidden = !selected
            
            if !selected {
                notesPopover.close()
                showInfo(false)
                deleteButton.tintActive = false
            }
        }
    }
    
    @IBOutlet var box: NSBox!
    var contentViewController: PostContentViewController! = nil
    var heightHoldingConstraint: NSLayoutConstraint!
    
    @IBOutlet var stackView: NSStackView!
    
    @IBOutlet var infoSlidingConstraint: NSLayoutConstraint!
    @IBOutlet var infoTextField: NSTextField!
    
    @IBOutlet var avatarConstraint: NSLayoutConstraint!
    @IBOutlet var avatarButton: NSButton!
    @IBOutlet var selectionCaret: NSView!
    @IBOutlet var blogNameButton: NSButton!
    @IBOutlet var reblogIcon: NSImageView!
    @IBOutlet var reblogNameButton: NSButton!
    
    @IBOutlet var tagsView: NSView!
    @IBOutlet var tagsScrollView: NSScrollView!
    @IBOutlet var tagsStackView: NSStackView!
    
    @IBOutlet var notesButton: NSButton!
    @IBOutlet var shareButton: NSButton!
    @IBOutlet var editButton: NSButton!
    @IBOutlet var deleteButton: ImageTintButton!
    @IBOutlet var reblogButton: ImageTintButton!
    @IBOutlet var likeButton: ImageTintButton!
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    required init() {
        super.init(frame: NSZeroRect)
    }
    
    override func awakeFromNib() {
        heightHoldingConstraint = NSLayoutConstraint(item: box, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        heightHoldingConstraint.priority = NSLayoutPriorityDefaultLow
        box.translatesAutoresizingMaskIntoConstraints = false
        heightHoldingConstraint.isActive = true
        box.contentView = nil
        shareButton.sendAction(on: NSEventMask(rawValue: UInt64(Int(NSEventMask.leftMouseDown.rawValue))))
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: BlogManager.BlogsLoaded), object: nil, queue: nil) { notification in
            self.updatePostControls()
        }
    }
    
    func configureView() {
        AvatarCache.sharedInstance.loadAvatar(post.blogName, size: 128, into: avatarButton)
        
        blogNameButton.title = post.blogName
        
        if let rebloggedName = post.rebloggedFromName {
            reblogIcon.isHidden = false
            reblogNameButton.isHidden = false
            reblogNameButton.title = rebloggedName
        } else {
            reblogIcon.isHidden = true
            reblogNameButton.isHidden = true
        }
        
        for view in tagsStackView!.views {
            tagsStackView.removeView(view)
        }
        
        tagsScrollView.horizontalScroller?.isHidden = true
        
        var footer1Hidden = true
        
        if let source = post.sourceTitle {
            footer1Hidden = false
            let sourceButton = Utils.createTextButton()
            sourceButton.target = self
            sourceButton.action = #selector(PostView.clickSourceButton(_:))
            sourceButton.title = "Source: \(source)"
            tagsStackView.addView(sourceButton, in: .center)
        }
        
        for (i, tag) in post.tags.enumerated() {
            footer1Hidden = false
            let tagButton = Utils.createTextButton()
            tagButton.target = self
            tagButton.action = #selector(PostView.clickTagButton(_:))
            tagButton.title = "#\(tag)"
            tagButton.tag = i
            tagsStackView.addView(tagButton, in: .center)
        }
        
        tagsView.isHidden = footer1Hidden
        
        updateNoteCount()
        
        likeButton.tintActive = post.liked
        updatePostControls()
        
        contentViewController = PostContentViewReuseManager.sharedInstance.viewControllerForType(post.type)
        box.contentView = contentViewController.view
        contentViewController.post = post
        
        box.removeConstraint(heightHoldingConstraint)
        
        var infoString = ""
        infoString += "Post ID: \(post.id)\n"
        infoString += "Published: \(PostView.infoDateFormatter.string(from: post.date as Date))\n"
        
        infoTextField.stringValue = infoString
    }
    
    // MARK: - State updating
    
    func updateNoteCount() {
        if post.noteCount == 0 {
            notesButton.title = ""
        } else if post.noteCount == 1 {
            notesButton.title = "\(PostView.notesFormatter.string(for: post.noteCount)!) note"
        } else {
            notesButton.title = "\(PostView.notesFormatter.string(for: post.noteCount)!) notes"
        }
    }
    
    func updatePostControls() {
        guard let name = post?.blogName else { return }
        
        let isMyBlog = BlogManager.sharedInstance.isMyBlog(name)
        
        editButton.isHidden = !isMyBlog
        deleteButton.isHidden = !isMyBlog
        likeButton.isHidden = isMyBlog
    }
    
    func updateHeight() {
        if let idx = controller.posts.index(of: post) {
            controller.updateHeight(idx)
        }
    }
    
    // MARK: - Post Actions
    
    @IBAction func openBlog(_ sender: AnyObject!) {
        NSWorkspace.shared().open(URL(string: "http://\(post.blogName).tumblr.com")!)
    }
    
    @IBAction func clickReblogNameButton(_ sender: AnyObject!) {
        NSWorkspace.shared().open(URL(string: post.rebloggedFromURL!)!)
    }
    
    @IBAction func clickPermalinkButton(_ sender: AnyObject!) {
        NSWorkspace.shared().open(URL(string: post.postURL)!)
    }
    
    @IBAction func showOnDash(_ sender: AnyObject!) {
        NSWorkspace.shared().open(URL(string: "https://tumblr.com/dashboard/2/\(post.id + 1)")!)
    }
    
    @IBAction func clickSourceButton(_ sender: AnyObject!) {
        NSWorkspace.shared().open(URL(string: post.sourceURL!)!)
    }
    
    @IBAction func clickTagButton(_ sender: NSButton) {
        var tag = post.tags[sender.tag]
        
        let charset = NSMutableCharacterSet(charactersIn: "/")
        charset.invert()
        charset.formIntersection(with: CharacterSet.urlPathAllowed)
        
        tag = tag.addingPercentEncoding(withAllowedCharacters: charset as CharacterSet)!
        tag = tag.replacingOccurrences(of: "%20", with: "-")
        
        let url: String
        
        if NSApp.currentEvent!.modifierFlags.contains(.command) {
            url = "http://\(post.blogName).tumblr.com/tagged/\(tag)"
        } else {
            url = "http://www.tumblr.com/tagged/\(tag)"
        }
        
        if let u = URL(string: url) {
            NSWorkspace.shared().open(u)
        }
    }
    
    lazy var notesController: NotesViewController = {
        let controller = self.window!.contentViewController!.storyboard!.instantiateController(withIdentifier: "notesViewController") as! NotesViewController
        controller.blog = self.post.blogName
        controller.id = self.post.id
        
        return controller
    }()
    
    let notesPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = NSPopoverBehavior.transient
        
        return popover
    }()
    
    @IBAction func showNotes(_ sender: AnyObject!) {
        if post.noteCount == 0 { return }
        
        notesController.refresh()
        notesPopover.contentViewController = notesController
        notesPopover.show(relativeTo: notesButton.bounds, of: notesButton, preferredEdge: .maxX)
    }
    
    @IBAction func share(_ sender: AnyObject!) {
        NSSharingServicePicker(items: [URL(string: post.postURL)!]).show(relativeTo: shareButton.bounds, of: shareButton, preferredEdge: .minY)
    }
    
    @IBAction func reblog(_ sender: AnyObject!) {
        if sender is NSButton {
            let event = NSApp.currentEvent!
            if event.modifierFlags.contains(.option) {
                if event.modifierFlags.contains(.command) {
                    reblogQueueQuick(sender)
                } else {
                    reblogQuick(sender)
                }
                
                return
            }
        }
        
        NSWorkspace.shared().open(URL(string: "https://www.tumblr.com/reblog/\(post.id)/\(post.reblogKey)")!)
        reblogButton.tintActive = true
        self.reblogButton.image = NSImage(named: "reblog")
        post.noteCount += 1; updateNoteCount()
    }
    
    var likeInProgress = false
    @IBAction func like(_ sender: AnyObject!) {
        if BlogManager.sharedInstance.isMyBlog(post.blogName) { return }
        if likeInProgress { return }
        
        likeInProgress = true
        if likeButton.tintActive {
            likeButton.tintActive = false
            post.noteCount -= 1; updateNoteCount()
            API.unlike(post.id, reblogKey: post.reblogKey) { (error: Error?) in
                if error != nil {
                    self.likeButton.tintActive = true
                    self.post.noteCount += 1; self.updateNoteCount()
                }
                
                self.likeInProgress = false
            }
        } else {
            likeButton.tintActive = true
            post.noteCount += 1; updateNoteCount()
            API.like(post.id, reblogKey: post.reblogKey) { (error: Error?) in
                if error != nil {
                    self.likeButton.tintActive = false
                    self.post.noteCount -= 1; self.updateNoteCount()
                }
                
                self.likeInProgress = false
            }
        }
    }
    
    @IBAction func edit(_ sender: AnyObject!) {
        if !BlogManager.sharedInstance.isMyBlog(post.blogName) { return }
        
        NSWorkspace.shared().open(URL(string: "https://www.tumblr.com/edit/\(post.id)")!)
    }
    
    @IBAction func deletePost(_ sender: AnyObject!) {
        if !BlogManager.sharedInstance.isMyBlog(post.blogName) { return }
        
        if deleteButton.tintActive {
            API.delete(post.blogName, id: post.id) { (error) in
                if error == nil {
                    self.controller.removePost(self.post)
                } else {
                    self.deleteButton.tintActive = true
                }
            }
        } else {
            deleteButton.tintActive = true
        }
    }
    
    @IBAction func reblogQuick(_ sender: AnyObject!) {
        guard let blogName = BlogManager.sharedInstance.currentBlogName else { return }
        
        reblogButton.tintActive = true
        self.reblogButton.image = NSImage(named: "reblog")
        post.noteCount += 1; updateNoteCount()
        
        API.reblog(blogName, id: post.id, reblogKey: post.reblogKey) { (error) in
            if error != nil {
                self.reblogButton.tintActive = false
                self.post.noteCount -= 1; self.updateNoteCount()
            }
        }
    }
    
    @IBAction func reblogQueueQuick(_ sender: AnyObject!) {
        guard let blogName = BlogManager.sharedInstance.currentBlogName else { return }
        
        reblogButton.tintActive = true
        post.noteCount += 1; updateNoteCount()
        
        API.reblog(blogName, id: post.id, reblogKey: post.reblogKey, parameters: ["state": "queue"]) { (error) in
            if error != nil {
                self.reblogButton.tintActive = false
                self.reblogButton.image = NSImage(named: "reblog")
                self.post.noteCount -= 1; self.updateNoteCount()
            } else {
                self.reblogButton.image = NSImage(named: "reblog_queue")
            }
        }
    }
    
    @IBAction func getInfo(_ sender: AnyObject!) {
        showInfo(infoSlidingConstraint.constant == 0)
    }
    
    func showInfo(_ flag: Bool) {
        infoSlidingConstraint.animator().constant = flag ? 300 : 0
    }
    
    // MARK: - Lifecycle/update messages
    
    func willAppear() {
        if contentViewController == nil {
            contentViewController = PostContentViewReuseManager.sharedInstance.viewControllerForType(post.type)
            box.contentView = contentViewController.view
            contentViewController.post = post
            
            box.removeConstraint(heightHoldingConstraint)
        }
    }
    
    func willDisappear() {
        if contentViewController != nil && visibleRect == NSZeroRect {
            heightHoldingConstraint.constant = contentViewController.view.bounds.size.height
            heightHoldingConstraint.isActive = true
            
            contentViewController.destroyView()
            PostContentViewReuseManager.sharedInstance.viewControllerRetiredForType(post.type, view: contentViewController)
            contentViewController = nil
            box.contentView = nil
        }
        
        notesPopover.close()
        showInfo(false)
        deleteButton.tintActive = false
    }
    
    lazy var topConstant: CGFloat = {
        return max((self.window as? WAYWindow)?.titleBarHeight ?? 0, CGFloat(WAYWindow.defaultTitleBarHeight())) + (self.enclosingScrollView?.contentInsets.top ?? 0)
    }()
    
    func positionChanged() {
        if contentViewController == nil {
            willAppear()
        }
        
        guard let w = window else { return }
        
        let visDiff2 = w.frame.size.height - (convert(frame.origin, to: w.contentView).y + frame.size.height)
        
        if visDiff2 >= topConstant {
            avatarConstraint.constant = 0
        } else {
            avatarConstraint.constant = topConstant - visDiff2
        }
    }
    
    func tearDown() {
        
    }
    
    func scrollTags(_ forward: Bool) {
        var r = tagsStackView.visibleRect
        r.origin.x += forward ? 100 : -100
        tagsStackView.scrollToVisible(r)
    }
    
    // MARK: - Formatters
    
    static let notesFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .decimal
        formatter.thousandSeparator = ","
        return formatter
    }()
    
    static let infoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter
    }()
    
}
