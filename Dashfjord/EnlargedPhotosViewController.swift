//
//  EnlargedPhotosViewController.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/15/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class EnlargedPhotosViewController: NSViewController {

    @IBOutlet var pageController: EnlargedPhotosPageController!
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserverForName(NSWindowDidExitFullScreenNotification, object: view.window, queue: nil) { (notification: NSNotification) in
            (notification.object as! NSWindow).close()
        }
    }
    
    @IBAction func close(sender: AnyObject!) {
        view.window!.toggleFullScreen(sender)
    }
    
}
