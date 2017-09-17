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
        case .off:
            invalidateDashboardCheckTimer()
            API.dashboard(["reblog_info": "true", "filter": "clean"], callback: refreshCallback)
        case .blog:
            API.posts(blog: "hacktail", parameters: ["reblog_info": "true", "filter": "clean"]) { posts, blog, error in
                self.refreshCallback(posts, error)
            }
        case .post:
            API.posts(blog: "", parameters: ["id": 0, "reblog_info": "true", "filter": "clean"]) { posts, blog, error in
                self.refreshCallback(posts, error)
                self.canLoadMore = false
                self.tableView.reloadData()
            }
        }
    }
    
    override func finishRefresh() {
        super.finishRefresh()
        setBadges(nil)
        
        if Utils.debug == .off {
            self.createDashboardCheckTimer()
        }
    }
    
    override func performLoadMore() {
        switch Utils.debug {
        case .off:
            API.dashboard(["offset": posts.count + filteredPosts, "reblog_info": "true", "filter": "clean"], callback: loadMoreCallback)
        case .blog:
            API.posts(blog: "hacktail", parameters: ["offset": posts.count + filteredPosts, "reblog_info": "true", "filter": "clean"]) { posts, blog, error in
                self.loadMoreCallback(posts, error)
            }
        case .post:
            break
        }
    }
    
    // MARK: - Dashboard post checking
    
    let dashboardCheckPostLimit = 10
    let dashboardCheckInterval: TimeInterval = 3 * 60
    var dashboardCheckTimer: Timer?
    
    func createDashboardCheckTimer() {
        if dashboardCheckTimer == nil {
            dashboardCheckTimer = Timer.scheduledTimer(timeInterval: dashboardCheckInterval, target: self, selector: #selector(DashboardViewController.fireDashboardCheckTimer(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func invalidateDashboardCheckTimer() {
        if dashboardCheckTimer != nil {
            dashboardCheckTimer!.invalidate()
            dashboardCheckTimer = nil
        }
    }
    
    func fireDashboardCheckTimer(_ timer: Timer?) {
        if Utils.debug == .off && posts.count > 0 {
            API.dashboard(["since_id": posts[0].id, "filter": "clean"]) { (posts: [Post]?, error: Error?) in
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
    
    func setBadges(_ string: String?) {
        (view.window?.windowController as? DashboardWindowController)?.setPostsBadge(string)
        NSApp.dockTile.badgeLabel = string
    }
    
}
