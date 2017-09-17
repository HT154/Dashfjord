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
        
        removeButton.isEnabled = tableView.selectedRowIndexes.count != 0
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filterManager.keywords.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return filterManager.keywords[row]
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        removeButton.isEnabled = tableView.selectedRowIndexes.count != 0
    }
    
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableRowActionEdge) -> [NSTableViewRowAction] {
        return [NSTableViewRowAction(style: .destructive, title: "Delete") { (action: NSTableViewRowAction, row: Int) in
            self.filterManager.keywords.remove(at: row)
            self.tableView.reloadData()
        }]
    }
    
    @IBAction func edit(_ sender: NSTextField!) {
        let row = tableView.row(for: sender)
        
        if row >= 0 {
            filterManager.keywords[row] = sender.stringValue
            filterManager.keywords.sort()
            tableView.reloadData()
        }
    }
    
    @IBAction func add(_ sender: AnyObject!) {
        filterManager.keywords.insert("", at: 0)
        tableView.reloadData()
        tableView.editColumn(0, row: 0, with: NSApp.currentEvent, select: true)
    }
    
    @IBAction func remove(_ sender: AnyObject!) {
        for index in tableView.selectedRowIndexes {
            self.filterManager.keywords.remove(at: index)
        }
        
        tableView.reloadData()
    }
    
}
