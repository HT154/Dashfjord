//
//  PostTableViewController.swift
//  Treadr
//
//  Created by Joshua Basch on 9/19/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, PullToRefreshScrollViewTarget {
    
    @IBOutlet var tableView: PostTableView!
    @IBOutlet var scrollView: PostScrollView!
    
    @IBOutlet var loadMoreView: NSTableCellView!
    @IBOutlet var loadMoreSpinner: NSProgressIndicator!
    
    let sizingWindow = NSWindow()
    var filteredPosts = 0
    
    var IDs: [Int] = []
    var views: [(cell: PostView, height: CGFloat)] = []
    var posts: [Post] = [] {
        didSet {
            IDs = posts.map { (post: Post) -> Int in
                return post.id
            }
        }
    }
    
    let nib = NSNib(nibNamed: "PostView", bundle: NSBundle.mainBundle())!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.target = self
        tableView.controller = self
        tableView.registerNib(nib, forIdentifier: "PostView")
        
        loadMoreSpinner.startAnimation(nil)
        
        NSNotificationCenter.defaultCenter().addObserverForName(ReachabilityChangedNotification, object: nil, queue: nil) { (note: NSNotification) -> Void in
            let reachability = note.object as! Reachability
            
            if reachability.isReachable() && self.posts.count == 0 {
                self.refresh(nil)
            }
        }
        
        refresh(nil)
    }
    
    override func viewDidAppear() {
        view.window?.makeFirstResponder(tableView)
    }
    
    func makePostView() -> PostView? {
        var view: PostView?
        var topLevel: NSArray?
        
        if nib.instantiateWithOwner(self, topLevelObjects: &topLevel) {
            for item in topLevel! {
                if item is PostView {
                    view = item as? PostView
                }
            }
        }
        
        NSLayoutConstraint(item: view!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 664).active = true
        
        return view
    }
    
    // MARK: - Post Loading
    
    var loadInProgress = false
    
    lazy var postViewMapper: (post: Post) -> (PostView, CGFloat) = { (post: Post) -> (PostView, CGFloat) in
        guard let cell = self.makePostView() else { return (PostView(), 0) }
        
        cell.post = post
        cell.controller = self
        
        let height = self.heightForCell(cell)
        
        cell.willDisappear()
        
        return (cell, height)
    }
    
    lazy var postFilter: (post: Post) -> Bool = { (post: Post) -> Bool in
        if PostFilterManager.sharedInstance.shouldFilter(post) {
            self.filteredPosts += 1
            return false
        }
        
        return true
    }
    
    // MARK: Refresh
    
    @IBAction func refresh(sender: AnyObject?) {
        if loadInProgress { return }
        loadInProgress = true
        
        performRefresh()
    }
    
    func performRefresh() {
        loadInProgress = false
    }
    
    func finishRefresh() {
        scrollToTop(nil)
        scrollView.loaded = true
    }
    
    lazy var refreshCallback: (posts: [Post]?, error: NSError?) -> Void = { (posts: [Post]?, error: NSError?) in
        self.scrollView.endRefreshing()
        
        if let e = error {
            print("posts load error: \(e)")
            self.loadInProgress = false
        } else {
            self.replacePosts(posts!)
            self.finishRefresh()
        }
    }
    
    func replacePosts(newPosts: [Post]) {
        canLoadMore = true
        selectedRow = -1
        
        for (cell, _) in views {
            cell.tearDown()
        }
        
        posts = newPosts.filter(postFilter)
        views = posts.map(postViewMapper)
        
        tableView.reloadData()
        tableView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
        loadInProgress = false
    }
    
    // MARK: Load More
    
    var canLoadMore = true
    
    func loadMore(sender: AnyObject?) {
        if loadInProgress || !canLoadMore { return }
        loadInProgress = true
        
        performLoadMore()
    }
    
    func performLoadMore() {
        loadInProgress = false
    }
    
    lazy var loadMoreCallback: (posts: [Post]?, error: NSError?) -> Void = { (posts: [Post]?, error: NSError?) in
        if let e = error {
            print("posts load error: \(e)")
            self.loadInProgress = false
        } else {
            self.addPosts(posts)
        }
    }
    
    func addPosts(newPosts: [Post]?) {
        guard let possiblePosts = newPosts else { return }
        
        var actualNewPosts: [Post] = []
        
        for post in possiblePosts {
            if !IDs.contains(post.id) {
                actualNewPosts.append(post)
            }
        }
        
        actualNewPosts = actualNewPosts.filter(postFilter)
        
        if actualNewPosts.count == 0 {
            canLoadMore = false
        } else {
            posts.insertContentsOf(actualNewPosts, at: posts.count)
            views.appendContentsOf(actualNewPosts.map(postViewMapper))
            
            tableView.reloadData()
            scrollView.reflectScrolledClipView(scrollView.contentView)
        }
        
        loadInProgress = false
    }
    
    let blankView = NSView()
    
    func heightForCell(cell: PostView) -> CGFloat {
        sizingWindow.contentView = cell
        sizingWindow.setFrame(self.sizingWindow.frameRectForContentRect(NSMakeRect(0, 0, cell.fittingSize.width, cell.fittingSize.height)), display: true, animate: false)
        
        let height = cell.fittingSize.height
        
        sizingWindow.contentView = blankView
        
        return height
    }
    
    // MARK: - Other
    
    func removePost(post: Post) {
        let idx = posts.indexOf(post)!
        posts.removeAtIndex(idx)
        views[idx].cell.tearDown()
        views.removeAtIndex(idx)
        tableView.reloadData()
        scrollView.reflectScrolledClipView(scrollView.contentView)
    }
    
    func updateHeight(idx: Int) {
        views[idx].height = heightForCell(views[idx].cell)
        tableView.noteHeightOfRowsWithIndexesChanged(NSIndexSet(index: idx))
        tableView.reloadDataForRowIndexes(NSIndexSet(index: idx), columnIndexes: NSIndexSet(index: 0))
    }
    
    // MARK: - NSTableViewDataSource/NSTableViewDelegate
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == posts.count { return 32 }
        
        return views[row].height
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row == posts.count { return loadMoreView }
        
        return views[row].cell
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return posts.count + (canLoadMore ? 1 : 0)
    }
    
    var selectedRow = -1 {
        willSet {
            if selectedRow >= 0 { views[selectedRow].cell.selected = false }
        }
        didSet {
            if selectedRow >= 0 { views[selectedRow].cell.selected = true }
        }
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        selectedRow = tableView.selectedRow
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return row != posts.count
    }
    
    // MARK: - Navigation
    
    @IBAction func nextPost(sender: AnyObject!) {
        if tableView.selectedRow == posts.count - 1 { return }
        
        tableView.selectRowIndexes(NSIndexSet(index: tableView.selectedRow + 1), byExtendingSelection: false)
        tableView.scrollRectToVisible(tableView.rectOfRow(tableView.selectedRow))
    }
    
    @IBAction func prevPost(sender: AnyObject!) {
        if tableView.selectedRow == 0 { return }
        
        tableView.selectRowIndexes(NSIndexSet(index: tableView.selectedRow - 1), byExtendingSelection: false)
        tableView.scrollRectToVisible(tableView.rectOfRow(tableView.selectedRow))
    }
    
    @IBAction func scrollToTop(sender: AnyObject!) {
        tableView.scrollRectToVisible(NSMakeRect(0, 0, 1, 1))
    }
    
    // MARK: - First responder redirection
    
    var selectedPost: PostView? {
        return tableView.viewAtColumn(0, row: tableView.selectedRow, makeIfNecessary: false) as? PostView
    }
    
    @IBAction func openBlog(sender: AnyObject!) { selectedPost?.openBlog(sender) }
    @IBAction func showOnDash(sender: AnyObject!) { selectedPost?.showOnDash(sender) }
    @IBAction func showNotes(sender: AnyObject!) { selectedPost?.showNotes(sender) }
    @IBAction func like(sender: AnyObject!) { selectedPost?.like(sender) }
    @IBAction func reblog(sender: AnyObject!) { selectedPost?.reblog(sender) }
    @IBAction func reblogQuick(sender: AnyObject!) { selectedPost?.reblogQuick(sender) }
    @IBAction func reblogQueueQuick(sender: AnyObject!) { selectedPost?.reblogQueueQuick(sender) }
    @IBAction func share(sender: AnyObject!) { selectedPost?.share(sender) }
    @IBAction func edit(sender: AnyObject!) { selectedPost?.edit(sender) }
    @IBAction func deletePost(sender: AnyObject!) { selectedPost?.deletePost(sender) }
    @IBAction func getInfo(sender: AnyObject!) { selectedPost?.getInfo(sender) }
    
    @IBAction func homeButton(sender: AnyObject!) { refresh(sender) }
    
}
