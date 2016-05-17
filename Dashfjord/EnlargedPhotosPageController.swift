//
//  EnlargedPhotosPageController.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/13/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class EnlargedPhotosPageController: NSPageController, NSPageControllerDelegate {
    
    var objectsToShow: [AnyObject]! = []
    var indexToSelect = 0
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserverForName(NSWindowDidEnterFullScreenNotification, object: view.window, queue: nil) { (notification: NSNotification) in
            self.arrangedObjects = self.objectsToShow
            self.selectedIndex = self.indexToSelect
        }
    }
    
    func pageController(pageController: NSPageController, identifierForObject object: AnyObject) -> String {
        return ""
    }
    
    func pageController(pageController: NSPageController, viewControllerForIdentifier identifier: String) -> NSViewController {
        let vc = NSViewController()
        let sv = NSScrollView()
        let iv = NSImageView(frame: view.window!.frame)
        
        vc.view = sv
        
        sv.documentView = iv
        sv.drawsBackground = false
        sv.allowsMagnification = true
        sv.magnification = 1
        sv.minMagnification = 1
        sv.maxMagnification = 4
        
        return vc
    }
    
    func pageController(pageController: NSPageController, prepareViewController viewController: NSViewController, withObject object: AnyObject) {
        if let img = object as? Photo {
            PhotoCache.sharedInstance.loadURL(img.URL, into: (viewController.view as! NSScrollView).documentView! as! NSImageView)
        }
    }
    
}
