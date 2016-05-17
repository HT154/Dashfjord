//
//  AppDelegate.swift
//  Treadr
//
//  Created by Joshua Basch on 9/19/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let keychain = Keychain(serviceName: "Dashfjord")
    
    lazy var storyboard = NSStoryboard(name: "Main", bundle: nil)
    
    var dashboardWindowController: DashboardWindowController!
    lazy var preferencesWindowController: NSWindowController = { self.storyboard.instantiateControllerWithIdentifier("preferencesWindow") as! NSWindowController }()
    lazy var authWindowController: NSWindowController = { self.storyboard.instantiateControllerWithIdentifier("authWindow") as! NSWindowController }()
    
    let reachability: Reachability? = {
        do {
            let reachability = try Reachability.reachabilityForInternetConnection()
            try reachability.startNotifier()
            
            return reachability
        } catch {
            print("Unable to create/start Reachability")
        }
        
        return nil
    }()
    
    @IBOutlet var blogMenu: NSMenu!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: #selector(AppDelegate.handleURLEvent(_:withReplyEvent:)), forEventClass: UInt32(kInternetEventClass), andEventID: UInt32(kAEGetURL))
        
        API.OAuthConsumerKey = "<consumer_key>"
        API.OAuthConsumerSecret = "<consumer_secret>"
        
        if let (token, tokenSecret) = retrieveTokens() {
            API.OAuthToken = token
            API.OAuthTokenSecret = tokenSecret
            
            launchAfterAuthorization()
        } else {
            authWindowController.showWindow(nil)
        }
    }
    
    func authorize() {
        let auth = TMTumblrAuthenticator.sharedInstance()
        auth.OAuthConsumerKey = API.OAuthConsumerKey
        auth.OAuthConsumerSecret = API.OAuthConsumerSecret
        
        auth.authenticate("dashfjord") { (token: String!, tokenSecret: String!, error: NSError!) -> Void in
            if error == nil {
                self.saveTokens(token, tokenSecret: tokenSecret)
                API.OAuthToken = token
                API.OAuthTokenSecret = tokenSecret
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.authWindowController.close()
                    self.launchAfterAuthorization()
                }
            } else {
                print("Authentication error: \(error)")
            }
        }
    }
    
    func launchAfterAuthorization() {
        BlogManager.sharedInstance.refresh()
        
        NSNotificationCenter.defaultCenter().addObserverForName(BlogManager.CurrentBlogChanged, object: nil, queue: nil) { (notification: NSNotification) in
            let blog = notification.object as! Blog
            
            for item in self.blogMenu.itemArray {
                item.state = item.title == blog.name ? NSOnState : NSOffState
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(BlogManager.BlogsLoaded, object: nil, queue: nil) { (notification: NSNotification) in
            let blogs = notification.object as! [Blog]
            
            self.blogMenu.removeAllItems()
            
            for (i, blog) in blogs.enumerate() {
                let item = NSMenuItem()
                item.tag = i
                item.title = blog.name
                item.target = self
                item.action = #selector(AppDelegate.changeBlog(_:))
                AvatarCache.sharedInstance.loadAvatar(blog.name, size: 32, into: item) {
                    $0.size = NSSize(width: 16, height: 16)
                }
                
                if i < 9 {
                    item.keyEquivalent = "\(i + 1)"
                    item.keyEquivalentModifierMask = Int(NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.AlternateKeyMask.rawValue)
                }
                
                self.blogMenu.addItem(item)
            }
        }
        
        dashboardWindowController = storyboard.instantiateControllerWithIdentifier("dashboardWindow") as! DashboardWindowController
        dashboardWindowController.showWindow(nil)
    }
    
    // MARK: - User Actions
    
    @IBAction func showDashboard(sender: AnyObject!) {
        if API.OAuthToken != "" {
            dashboardWindowController.showWindow(nil)
        }
    }
    
    @IBAction func showPreferences(sender: AnyObject!) {
        preferencesWindowController.showWindow(nil)
    }
    
    @IBAction func changeBlog(sender: NSMenuItem!) {
        BlogManager.sharedInstance.currentBlogName = BlogManager.sharedInstance.blogs[sender.tag].name
    }
    
    @IBAction func logOut(sender: AnyObject!) {
        let alert = NSAlert()
        alert.messageText = "Are you sure you want to log out?"
        alert.addButtonWithTitle("Cancel")
        alert.addButtonWithTitle("Log Out")
        
        if alert.runModal() == NSAlertSecondButtonReturn {
            deleteTokens()
            dashboardWindowController.close()
            authWindowController.showWindow(sender)
        }
    }
    
    // MARK: - Keychain Management
    
    func deleteTokens() {
        keychain.remove(GenericKey(keyName: "OAuth Token"))
        keychain.remove(GenericKey(keyName: "OAuth Token Secret"))
        API.OAuthToken = ""
        API.OAuthTokenSecret = ""
    }
    
    func saveTokens(token: String, tokenSecret: String) {
        keychain.add(GenericKey(keyName: "OAuth Token", value: token))
        keychain.add(GenericKey(keyName: "OAuth Token Secret", value: tokenSecret))
    }
    
    func retrieveTokens() -> (String, String)? {
        guard let token = keychain.get(GenericKey(keyName: "OAuth Token")).item?.value as? String else { return nil }
        guard let tokenSecret = keychain.get(GenericKey(keyName: "OAuth Token Secret")).item?.value as? String else { return nil }
        
        return (token, tokenSecret)
    }
    
    func handleURLEvent(event: NSAppleEventDescriptor, withReplyEvent: NSAppleEventDescriptor) {
        TMTumblrAuthenticator.sharedInstance().handleOpenURL(NSURL(string: event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))!.stringValue!)!)
    }
    
}
