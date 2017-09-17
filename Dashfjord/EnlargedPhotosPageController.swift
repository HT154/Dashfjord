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
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSWindowDidEnterFullScreen, object: view.window, queue: nil) { (notification: Notification) in
            self.arrangedObjects = self.objectsToShow
            self.selectedIndex = self.indexToSelect
        }
    }
    
    func pageController(_ pageController: NSPageController, identifierFor object: Any) -> String {
        return ""
    }
    
    func pageController(_ pageController: NSPageController, viewControllerForIdentifier identifier: String) -> NSViewController {
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
    
    func pageController(_ pageController: NSPageController, prepare viewController: NSViewController, with object: Any?) {
        if let img = object as? Photo {
            PhotoCache.sharedInstance.loadURL(img.URL, into: (viewController.view as! NSScrollView).documentView! as! NSImageView)
        }
    }
    
}
