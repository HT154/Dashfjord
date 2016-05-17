//
//  FilterPreferencesViewController.swift
//  Dashfjord
//
//  Created by Joshua Basch on 11/13/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class FilterPreferencesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    let filterManager = PostFilterManager.sharedInstance
    
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var addButton: NSButton!
    @IBOutlet var removeButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeButton.enabled = tableView.selectedRowIndexes.count != 0
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return filterManager.keywords.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return filterManager.keywords[row]
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        removeButton.enabled = tableView.selectedRowIndexes.count != 0
    }
    
    func tableView(tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableRowActionEdge) -> [NSTableViewRowAction] {
        return [NSTableViewRowAction(style: .Destructive, title: "Delete") { (action: NSTableViewRowAction, row: Int) in
            self.filterManager.keywords.removeAtIndex(row)
            self.tableView.reloadData()
        }]
    }
    
    @IBAction func edit(sender: NSTextField!) {
        let row = tableView.rowForView(sender)
        
        if row >= 0 {
            filterManager.keywords[row] = sender.stringValue
            filterManager.keywords.sortInPlace()
            tableView.reloadData()
        }
    }
    
    @IBAction func add(sender: AnyObject!) {
        filterManager.keywords.insert("", atIndex: 0)
        tableView.reloadData()
        tableView.editColumn(0, row: 0, withEvent: NSApp.currentEvent, select: true)
    }
    
    @IBAction func remove(sender: AnyObject!) {
        tableView.selectedRowIndexes.enumerateIndexesWithOptions([.Reverse]) { (row: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            self.filterManager.keywords.removeAtIndex(row)
        }
        
        tableView.reloadData()
    }
    
}
