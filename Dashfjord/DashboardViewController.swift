//
//  DashboardViewController.swift
//  Treadr
//
//  Created by Joshua Basch on 9/19/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class DashboardViewController: PostTableViewController {
    
    override func performRefresh() {
        switch Utils.debug {
        case .Off:
            invalidateDashboardCheckTimer()
            API.dashboard(["reblog_info": "true", "filter": "clean"], callback: refreshCallback)
        case .Blog:
            API.posts(blog: "hacktail", parameters: ["reblog_info": "true", "filter": "clean"]) { posts, blog, error in
                self.refreshCallback(posts: posts, error: error)
            }
        case .Post:
            API.posts(blog: "", parameters: ["id": 0, "reblog_info": "true", "filter": "clean"]) { posts, blog, error in
                self.refreshCallback(posts: posts, error: error)
                self.canLoadMore = false
                self.tableView.reloadData()
            }
        }
    }
    
    override func finishRefresh() {
        super.finishRefresh()
        setBadges(nil)
        
        if Utils.debug == .Off {
            self.createDashboardCheckTimer()
        }
    }
    
    override func performLoadMore() {
        switch Utils.debug {
        case .Off:
            API.dashboard(["offset": posts.count + filteredPosts, "reblog_info": "true", "filter": "clean"], callback: loadMoreCallback)
        case .Blog:
            API.posts(blog: "hacktail", parameters: ["offset": posts.count + filteredPosts, "reblog_info": "true", "filter": "clean"]) { posts, blog, error in
                self.loadMoreCallback(posts: posts, error: error)
            }
        case .Post:
            break
        }
    }
    
    // MARK: - Dashboard post checking
    
    let dashboardCheckPostLimit = 10
    let dashboardCheckInterval: NSTimeInterval = 3 * 60
    var dashboardCheckTimer: NSTimer?
    
    func createDashboardCheckTimer() {
        if dashboardCheckTimer == nil {
            dashboardCheckTimer = NSTimer.scheduledTimerWithTimeInterval(dashboardCheckInterval, target: self, selector: #selector(DashboardViewController.fireDashboardCheckTimer(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func invalidateDashboardCheckTimer() {
        if dashboardCheckTimer != nil {
            dashboardCheckTimer!.invalidate()
            dashboardCheckTimer = nil
        }
    }
    
    func fireDashboardCheckTimer(timer: NSTimer?) {
        if Utils.debug == .Off && posts.count > 0 {
            API.dashboard(["since_id": posts[0].id, "filter": "clean"]) { (posts: [Post]?, error: NSError?) in
                if var p = posts {
                    p = p.filter { !PostFilterManager.sharedInstance.shouldFilter($0) }
                    
                    let count = p.count
                    
                    if count == 0 {
                        self.setBadges(nil)
                    } else if count >= self.dashboardCheckPostLimit {
                        self.invalidateDashboardCheckTimer()
                        self.setBadges("\(self.dashboardCheckPostLimit)+")
                    } else {
                        self.setBadges("\(count)")
                    }
                }
            }
        }
    }
    
    func setBadges(string: String?) {
        (view.window?.windowController as? DashboardWindowController)?.setPostsBadge(string)
        NSApp.dockTile.badgeLabel = string
    }
    
}
