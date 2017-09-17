//
//  BlogsViewController.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/4/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class BlogsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet var tableView: NSTableView!
    private var causedBlogChange = false
    private var causedSelectionChange = false
    weak var popover: NSPopover?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: BlogManager.CurrentBlogChanged), object: nil, queue: nil) { (notification: Notification) in
            if self.causedBlogChange {
                self.causedBlogChange = false
            } else {
                self.causedSelectionChange = true
                let index = BlogManager.sharedInstance.blogs.index(of: BlogManager.sharedInstance.currentBlog!)!
                self.tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
                self.tableView.scrollRowToVisible(index)
            }
        }
    }
    
    override func viewWillAppear() {
        causedSelectionChange = true
        tableView.reloadData()
        
        if let current = BlogManager.sharedInstance.currentBlog {
            let index = BlogManager.sharedInstance.blogs.index(of: current)!
            if tableView.selectedRow != index {
                causedSelectionChange = true
                tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
                tableView.scrollRowToVisible(index)
            }
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if causedSelectionChange {
            causedSelectionChange = false
        } else {
            causedBlogChange = true
            BlogManager.sharedInstance.currentBlogName = BlogManager.sharedInstance.blogs[tableView.selectedRow].name
            popover?.close()
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return BlogManager.sharedInstance.blogs.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.make(withIdentifier: "blogTableCellView", owner: nil) as! BlogTableCellView
        view.blog = BlogManager.sharedInstance.blogs[row]
        return view
    }
    
}
