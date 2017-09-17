//
//  PostTableView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 11/26/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostTableView: NSTableView {

    var controller: PostTableViewController?
    
    override func keyDown(with event: NSEvent) {
        let flags = event.modifierFlags
        
        switch event.keyCode {
        case 49: //spacebar
            scroll(enclosingScrollView!.bounds.size.height * 0.75)
        case 123: // left arrow
            controller?.selectedPost?.scrollTags(false)
        case 124: // right arrow
            controller?.selectedPost?.scrollTags(true)
        case 125: //down arrow
            if !flags.contains(.option) {
                scroll(300)
            } else {
                scroll(enclosingScrollView!.bounds.size.height * 0.75)
            }
        case 126: //up arrow
            if !flags.contains(.option) {
                scroll(-300)
            } else {
                scroll(-enclosingScrollView!.bounds.size.height * 0.75)
            }
        default: super.keyDown(with: event)
        }
    }
    
    func scroll(_ offset: CGFloat) {
        var r = visibleRect
        r.origin.y += offset
        scrollToVisible(r)
    }
    
}
