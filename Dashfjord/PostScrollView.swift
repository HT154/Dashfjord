//
//  PostScrollView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 11/26/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostScrollView: PullToRefreshScrollView {
    
    var prev = Set<Int>()
    
    override func reflectScrolledClipView(_ cView: NSClipView) {
        super.reflectScrolledClipView(cView)
        
        guard let tableView = documentView as? NSTableView else { return }
        
        let visible = tableView.rows(in: tableView.visibleRect)
        
        // Selection
        
        if !NSLocationInRange(tableView.selectedRow, visible) {
            let newIndex: Int
            
            if tableView.selectedRow < visible.location {
                newIndex = visible.location
            } else {
                newIndex = visible.location + visible.length - 1
            }
            
            tableView.selectRowIndexes(IndexSet(integer: newIndex), byExtendingSelection: false)
        }
        
        // Visibility
        
        var curr = Set<Int>()
        for i in 0..<visible.length {
            curr.insert(visible.location + i)
        }
        
        let lost = prev.subtracting(curr)
        let found = curr.subtracting(prev)
        
        for idx in lost {
            if idx < tableView.numberOfRows {
                (tableView.view(atColumn: 0, row: idx, makeIfNecessary: false) as? PostView)?.willDisappear()
            }
        }
        
        for idx in found {
            if idx < tableView.numberOfRows {
                (tableView.view(atColumn: 0, row: idx, makeIfNecessary: false) as? PostView)?.willAppear()
            }
        }
        
        for idx in curr {
            if idx < tableView.numberOfRows {
                (tableView.view(atColumn: 0, row: idx, makeIfNecessary: false) as? PostView)?.positionChanged()
            }
        }
        
        prev = curr
    }
    
}
