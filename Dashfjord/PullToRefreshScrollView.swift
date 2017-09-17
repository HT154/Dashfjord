//
//  PullToRefreshScrollView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/27/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

protocol PullToRefreshScrollViewTarget {
    func refresh(_ sender: AnyObject?)
    func loadMore(_ sender: AnyObject?)
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
            pullToRefreshIndicator!.isHidden = true
            pullToRefreshIndicator!.stopAnimation(nil)
        }
    }
    
    override func reflectScrolledClipView(_ cView: NSClipView) {
        super.reflectScrolledClipView(cView)
        
        if loaded && documentVisibleRect.origin.y + bounds.size.height - documentView!.bounds.size.height > -loadMoreThreshold {
            target?.loadMore(self)
        }
    }
    
    override func scrollWheel(with theEvent: NSEvent) {
        super.scrollWheel(with: theEvent)
        
        guard let refreshIndicator = pullToRefreshIndicator else { return }
        
        if !refreshing && theEvent.phase == .began && theEvent.scrollingDeltaY > 0 && verticalScroller!.doubleValue == 0 {
            refreshIndicator.isIndeterminate = false
            refreshIndicator.isHidden = false
            possiblyRefreshing = true
        }
        
        if possiblyRefreshing {
            refreshIndicator.doubleValue = Double(-documentVisibleRect.origin.y - 24) //pullToRefreshIndicator has min=0 and max=20
        }
        
        if possiblyRefreshing && !refreshing && theEvent.phase == .ended {
            if -documentVisibleRect.origin.y > 44 {
                refreshIndicator.isIndeterminate = true
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
        
        if theEvent.momentumPhase == .ended {
            possiblyRefreshing = false
            
            if !refreshing {
                refreshIndicator.isHidden = true
            }
        }
    }
    
}
