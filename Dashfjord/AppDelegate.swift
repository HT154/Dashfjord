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
    lazy var preferencesWindowController: NSWindowController = { self.storyboard.instantiateController(withIdentifier: "preferencesWindow") as! NSWindowController }()
    lazy var authWindowController: NSWindowController = { self.storyboard.instantiateController(withIdentifier: "authWindow") as! NSWindowController }()
    
//    let reachability: Reachability? = {
//        do {
//            let reachability = try Reachability.reachabilityForInternetConnection()
//            try reachability.startNotifier()
//            
//            return reachability
//        } catch {
//            print("Unable to create/start Reachability")
//        }
//        
//        return nil
//    }()
    
    @IBOutlet var blogMenu: NSMenu!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(AppDelegate.handleURLEvent(_:withReplyEvent:)), forEventClass: UInt32(kInternetEventClass), andEventID: UInt32(kAEGetURL))
        
        API.OAuthConsumerKey = "QnGtoic9XD0Qc57Rvr31DT2ZNEcqkn187JZH6nFD4TRvy9znTZ"
        API.OAuthConsumerSecret = "1VvRaoMba9YUriaqBW0xUq8sO8tQShdT39oa5G4l9WfNDRxQIW"
        
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
        auth?.oAuthConsumerKey = API.OAuthConsumerKey
        auth?.oAuthConsumerSecret = API.OAuthConsumerSecret
        
        auth?.authenticate("dashfjord") { token, tokenSecret, error in
            if error == nil {
                self.saveTokens(token!, tokenSecret: tokenSecret!)
                API.OAuthToken = token!
                API.OAuthTokenSecret = tokenSecret!
                
                DispatchQueue.main.async {
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
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: BlogManager.CurrentBlogChanged), object: nil, queue: nil) { (notification: Notification) in
            guard let blog = notification.object as? Blog
                else { return }
            
            for item in self.blogMenu.items {
                item.state = item.title == blog.name ? NSOnState : NSOffState
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: BlogManager.BlogsLoaded), object: nil, queue: nil) { (notification: Notification) in
            let blogs = notification.object as! [Blog]
            
            self.blogMenu.removeAllItems()
            
            for (i, blog) in blogs.enumerated() {
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
                    item.keyEquivalentModifierMask = [.command, .option]
                }
                
                self.blogMenu.addItem(item)
            }
        }
        
        dashboardWindowController = storyboard.instantiateController(withIdentifier: "dashboardWindow") as! DashboardWindowController
        dashboardWindowController.showWindow(nil)
    }
    
    // MARK: - User Actions
    
    @IBAction func showDashboard(_ sender: AnyObject!) {
        if API.OAuthToken != "" {
            dashboardWindowController.showWindow(nil)
        }
    }
    
    @IBAction func showPreferences(_ sender: AnyObject!) {
        preferencesWindowController.showWindow(nil)
    }
    
    @IBAction func changeBlog(_ sender: NSMenuItem!) {
        BlogManager.sharedInstance.currentBlogName = BlogManager.sharedInstance.blogs[sender.tag].name
    }
    
    @IBAction func logOut(_ sender: AnyObject!) {
        let alert = NSAlert()
        alert.messageText = "Are you sure you want to log out?"
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Log Out")
        
        if alert.runModal() == NSAlertSecondButtonReturn {
            deleteTokens()
            dashboardWindowController.close()
            authWindowController.showWindow(sender)
        }
    }
    
    // MARK: - Keychain Management
    
    func deleteTokens() {
        _ = keychain.remove(GenericKey(keyName: "OAuth Token"))
        _ = keychain.remove(GenericKey(keyName: "OAuth Token Secret"))
        API.OAuthToken = ""
        API.OAuthTokenSecret = ""
    }
    
    func saveTokens(_ token: String, tokenSecret: String) {
        _ = keychain.add(GenericKey(keyName: "OAuth Token", value: token as NSString?))
        _ = keychain.add(GenericKey(keyName: "OAuth Token Secret", value: tokenSecret as NSString?))
    }
    
    func retrieveTokens() -> (String, String)? {
        guard let token = keychain.get(GenericKey(keyName: "OAuth Token")).item?.value as? String else { return nil }
        guard let tokenSecret = keychain.get(GenericKey(keyName: "OAuth Token Secret")).item?.value as? String else { return nil }
        
        return (token, tokenSecret)
    }
    
    func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent: NSAppleEventDescriptor) {
        TMTumblrAuthenticator.sharedInstance().handleOpen(URL(string: event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))!.stringValue!)!)
    }
    
}
