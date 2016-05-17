//
//  NotesViewController.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/8/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class NotesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet var tableView: NSTableView!
    
    var blog: String!
    var id: Int!
    
    var notes: [Note] = []
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        notes = []
        tableView.reloadData()
    }
    
    func refresh() {
        API.notes(blog, id: id) { (notes, error) in
            if notes != nil {
                self.notes = notes!.filter { note -> Bool in
                    return note.type != .Posted
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return notes.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeViewWithIdentifier("noteTableCellView", owner: nil) as! NoteTableCellView
        view.note = notes[row]
        return view
    }
    
}