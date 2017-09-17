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
    
    let nib = NSNib(nibNamed: "PostView", bundle: Bundle.main)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.target = self
        tableView.controller = self
        tableView.register(nib, forIdentifier: "PostView")
        
        loadMoreSpinner.startAnimation(nil)
        
//        NotificationCenter.default().addObserver(forName: NSNotification.Name(rawValue: ReachabilityChangedNotification), object: nil, queue: nil) { (note: Notification) -> Void in
//            let reachability = note.object as! Reachability
//            
//            if reachability.isReachable() && self.posts.count == 0 {
//                self.refresh(nil)
//            }
//        }
        
        refresh(nil)
    }
    
    override func viewDidAppear() {
        view.window?.makeFirstResponder(tableView)
    }
    
    func makePostView() -> PostView? {
        var view: PostView?
        var topLevel: NSArray = []
        
        if nib.instantiate(withOwner: self, topLevelObjects: &topLevel) {
            for item in topLevel {
                if item is PostView {
                    view = item as? PostView
                }
            }
        }
        
        NSLayoutConstraint(item: view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 664).isActive = true
        
        return view
    }
    
    // MARK: - Post Loading
    
    var loadInProgress = false
    
    lazy var postViewMapper: (_ post: Post) -> (PostView, CGFloat) = { (post: Post) -> (PostView, CGFloat) in
        guard let cell = self.makePostView() else { return (PostView(), 0) }
        
        cell.post = post
        cell.controller = self
        
        let height = self.heightForCell(cell)
        
        cell.willDisappear()
        
        return (cell, height)
    }
    
    lazy var postFilter: (_ post: Post) -> Bool = { (post: Post) -> Bool in
        if PostFilterManager.sharedInstance.shouldFilter(post) {
            self.filteredPosts += 1
            return false
        }
        
        return true
    }
    
    // MARK: Refresh
    
    @IBAction func refresh(_ sender: AnyObject?) {
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
    
    lazy var refreshCallback: (_ posts: [Post]?, _ error: Error?) -> Void = { (posts: [Post]?, error: Error?) in
        self.scrollView.endRefreshing()
        
        if let e = error {
            print("posts load error: \(e)")
            self.loadInProgress = false
        } else {
            self.replacePosts(posts!)
            self.finishRefresh()
        }
    }
    
    func replacePosts(_ newPosts: [Post]) {
        canLoadMore = true
        selectedRow = -1
        
        for (cell, _) in views {
            cell.tearDown()
        }
        
        posts = newPosts.filter(postFilter)
        views = posts.map(postViewMapper)
        
        tableView.reloadData()
        tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        loadInProgress = false
    }
    
    // MARK: Load More
    
    var canLoadMore = true
    
    func loadMore(_ sender: AnyObject?) {
        if loadInProgress || !canLoadMore { return }
        loadInProgress = true
        
        performLoadMore()
    }
    
    func performLoadMore() {
        loadInProgress = false
    }
    
    lazy var loadMoreCallback: (_ posts: [Post]?, _ error: Error?) -> Void = { (posts: [Post]?, error: Error?) in
        if let e = error {
            print("posts load error: \(e)")
            self.loadInProgress = false
        } else {
            self.addPosts(posts)
        }
    }
    
    func addPosts(_ newPosts: [Post]?) {
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
            posts.insert(contentsOf: actualNewPosts, at: posts.count)
            views.append(contentsOf: actualNewPosts.map(postViewMapper))
            
            tableView.reloadData()
            scrollView.reflectScrolledClipView(scrollView.contentView)
        }
        
        loadInProgress = false
    }
    
    let blankView = NSView()
    
    func heightForCell(_ cell: PostView) -> CGFloat {
        sizingWindow.contentView = cell
        sizingWindow.setFrame(self.sizingWindow.frameRect(forContentRect: NSMakeRect(0, 0, cell.fittingSize.width, cell.fittingSize.height)), display: true, animate: false)
        
        let height = cell.fittingSize.height
        
        sizingWindow.contentView = blankView
        
        return height
    }
    
    // MARK: - Other
    
    func removePost(_ post: Post) {
        let idx = posts.index(of: post)!
        posts.remove(at: idx)
        views[idx].cell.tearDown()
        views.remove(at: idx)
        tableView.reloadData()
        scrollView.reflectScrolledClipView(scrollView.contentView)
    }
    
    func updateHeight(_ idx: Int) {
        views[idx].height = heightForCell(views[idx].cell)
        tableView.noteHeightOfRows(withIndexesChanged: IndexSet(integer: idx))
        tableView.reloadData(forRowIndexes: IndexSet(integer: idx), columnIndexes: IndexSet(integer: 0))
    }
    
    // MARK: - NSTableViewDataSource/NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == posts.count { return 32 }
        
        return views[row].height
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row == posts.count { return loadMoreView }
        
        return views[row].cell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedRow = tableView.selectedRow
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return row != posts.count
    }
    
    // MARK: - Navigation
    
    @IBAction func nextPost(_ sender: AnyObject!) {
        if tableView.selectedRow == posts.count - 1 { return }
        
        tableView.selectRowIndexes(IndexSet(integer: tableView.selectedRow + 1), byExtendingSelection: false)
        tableView.scrollToVisible(tableView.rect(ofRow: tableView.selectedRow))
    }
    
    @IBAction func prevPost(_ sender: AnyObject!) {
        if tableView.selectedRow == 0 { return }
        
        tableView.selectRowIndexes(IndexSet(integer: tableView.selectedRow - 1), byExtendingSelection: false)
        tableView.scrollToVisible(tableView.rect(ofRow: tableView.selectedRow))
    }
    
    @IBAction func scrollToTop(_ sender: AnyObject!) {
        tableView.scrollToVisible(NSMakeRect(0, 0, 1, 1))
    }
    
    // MARK: - First responder redirection
    
    var selectedPost: PostView? {
        return tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: false) as? PostView
    }
    
    @IBAction func openBlog(_ sender: AnyObject!) { selectedPost?.openBlog(sender) }
    @IBAction func showOnDash(_ sender: AnyObject!) { selectedPost?.showOnDash(sender) }
    @IBAction func showNotes(_ sender: AnyObject!) { selectedPost?.showNotes(sender) }
    @IBAction func like(_ sender: AnyObject!) { selectedPost?.like(sender) }
    @IBAction func reblog(_ sender: AnyObject!) { selectedPost?.reblog(sender) }
    @IBAction func reblogQuick(_ sender: AnyObject!) { selectedPost?.reblogQuick(sender) }
    @IBAction func reblogQueueQuick(_ sender: AnyObject!) { selectedPost?.reblogQueueQuick(sender) }
    @IBAction func share(_ sender: AnyObject!) { selectedPost?.share(sender) }
    @IBAction func edit(_ sender: AnyObject!) { selectedPost?.edit(sender) }
    @IBAction func deletePost(_ sender: AnyObject!) { selectedPost?.deletePost(sender) }
    @IBAction func getInfo(_ sender: AnyObject!) { selectedPost?.getInfo(sender) }
    
    @IBAction func homeButton(_ sender: AnyObject!) { refresh(sender) }
    
}
