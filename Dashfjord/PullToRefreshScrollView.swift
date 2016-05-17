//
//  PullToRefreshScrollView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/27/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

protocol PullToRefreshScrollViewTarget {
    func refresh(sender: AnyObject?)
    func loadMore(sender: AnyObject?)
}

class PullToRefreshScrollView: NSScrollView {
    
    @IBOutlet var pullToRefreshIndicator: NSProgressIndicator?
    var target: PullToRefreshScrollViewTarget?
    var loaded = false
    
    var loadMoreThreshold: CGFloat = 1000
    
    private var possiblyRefreshing = false
    private var refreshing = false
    private var originalContentInsets = NSEdgeInsetsZero
    private var originalScrollerInsets = NSEdgeInsetsZero
    
    override func awakeFromNib() {
        originalScrollerInsets = NSEdgeInsetsMake(-contentInsets.top, 0, 0, 0)
        scrollerInsets = originalScrollerInsets
    }
    
    func endRefreshing() {
        if refreshing {
            scrollerInsets = originalScrollerInsets
            contentInsets = originalContentInsets
            refreshing = false
            pullToRefreshIndicator!.hidden = true
            pullToRefreshIndicator!.stopAnimation(nil)
        }
    }
    
    override func reflectScrolledClipView(cView: NSClipView) {
        super.reflectScrolledClipView(cView)
        
        if loaded && documentVisibleRect.origin.y + bounds.size.height - documentView!.bounds.size.height > -loadMoreThreshold {
            target?.loadMore(self)
        }
    }
    
    override func scrollWheel(theEvent: NSEvent) {
        super.scrollWheel(theEvent)
        
        guard let refreshIndicator = pullToRefreshIndicator else { return }
        
        if !refreshing && theEvent.phase == .Began && theEvent.scrollingDeltaY > 0 && verticalScroller!.doubleValue == 0 {
            refreshIndicator.indeterminate = false
            refreshIndicator.hidden = false
            possiblyRefreshing = true
        }
        
        if possiblyRefreshing {
            refreshIndicator.doubleValue = Double(-documentVisibleRect.origin.y - 24) //pullToRefreshIndicator has min=0 and max=20
        }
        
        if possiblyRefreshing && !refreshing && theEvent.phase == .Ended {
            if -documentVisibleRect.origin.y > 44 {
                refreshIndicator.indeterminate = true
                refreshIndicator.startAnimation(nil)
                
                refreshing = true
                
                originalContentInsets = contentInsets
                originalScrollerInsets = scrollerInsets
                
                var newContentInsets = contentInsets
                var newScrollerInsets = contentInsets
                newContentInsets.top += 44
                newScrollerInsets.top -= 44 + contentInsets.top
                contentInsets = newContentInsets
                scrollerInsets = newScrollerInsets
                
                target?.refresh(self)
            }
        }
        
        if theEvent.momentumPhase == .Ended {
            possiblyRefreshing = false
            
            if !refreshing {
                refreshIndicator.hidden = true
            }
        }
    }
    
}
