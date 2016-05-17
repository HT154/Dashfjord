//
//  CenteringTabViewController.swift
//  Strack
//
//  Created by Joshua Basch on 9/22/14.
//  Copyright (c) 2014 HT154. All rights reserved.
//

import Cocoa

class CenteringTabViewController: NSTabViewController {
    
    override func toolbarDefaultItemIdentifiers(toolbar: NSToolbar) -> [String] {
        var ids = super.toolbarDefaultItemIdentifiers(toolbar)
        
        ids.insert(NSToolbarFlexibleSpaceItemIdentifier, atIndex: 0)
        ids.append(NSToolbarFlexibleSpaceItemIdentifier)
        
        return ids
    }

}
