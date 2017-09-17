//
//  CenteringTabViewController.swift
//  Strack
//
//  Created by Joshua Basch on 9/22/14.
//  Copyright (c) 2014 HT154. All rights reserved.
//

import Cocoa

class CenteringTabViewController: NSTabViewController {
    
    override func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        var ids = super.toolbarDefaultItemIdentifiers(toolbar)
        
        ids.insert(NSToolbarFlexibleSpaceItemIdentifier, at: 0)
        ids.append(NSToolbarFlexibleSpaceItemIdentifier)
        
        return ids
    }

}
