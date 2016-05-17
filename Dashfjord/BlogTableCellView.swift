//
//  BlogTableCellView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/4/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class BlogTableCellView: NSTableCellView {
    
    @IBOutlet var avatarImageView: NSImageView!
    @IBOutlet var blogNameField: NSTextField!
    @IBOutlet var blogTitleField: NSTextField!
    
    @IBOutlet var primaryPostsButton: TextTintButton!
    @IBOutlet var primaryFollowersButton: TextTintButton!
    @IBOutlet var primaryMessagesButton: TextTintButton!
    @IBOutlet var primaryDraftsButton: TextTintButton!
    @IBOutlet var primaryQueueButton: TextTintButton!
    
    @IBOutlet var secondaryPostsField: NSTextField!
    @IBOutlet var secondaryFollowersField: NSTextField!
    @IBOutlet var secondaryMessagesField: NSTextField!
    @IBOutlet var secondaryDraftsField: NSTextField!
    @IBOutlet var secondaryQueueField: NSTextField!
    
    var blog: Blog! {
        didSet {
            if blog != nil {
                blogNameField.stringValue = blog.name
                blogTitleField.stringValue = blog.title
                secondaryPostsField.stringValue = "\(blog.posts!)"
                secondaryFollowersField.stringValue = "\(blog.followers!)"
                secondaryMessagesField.stringValue = "\(blog.messages!)"
                secondaryDraftsField.stringValue = "\(blog.drafts!)"
                secondaryQueueField.stringValue = "\(blog.queue!)"
                AvatarCache.sharedInstance.loadAvatar(blog.name, size: 64, into: avatarImageView)
            }
        }
    }
    
    let primaryColorInactive = NSColor(calibratedWhite: 52.0/255, alpha: 1)
    let secondaryColorInactive = NSColor(calibratedWhite: 108.0/255, alpha: 1)
    let primaryColorActive = NSColor.whiteColor()
    let secondaryColorActive = NSColor(calibratedWhite: 227.0/255, alpha: 1)
    
    override var backgroundStyle: NSBackgroundStyle {
        set {
            super.backgroundStyle = newValue
            
            if newValue == .Dark {
                blogNameField.textColor = primaryColorActive
                for button in [primaryPostsButton, primaryFollowersButton, primaryMessagesButton, primaryDraftsButton, primaryQueueButton] {
                    button.color = primaryColorActive
                }
                
                for field in [blogTitleField, secondaryPostsField, secondaryFollowersField, secondaryMessagesField, secondaryDraftsField, secondaryQueueField] {
                    field.textColor = secondaryColorActive
                }
            } else {
                blogNameField.textColor = primaryColorInactive
                for button in [primaryPostsButton, primaryFollowersButton, primaryMessagesButton, primaryDraftsButton, primaryQueueButton] {
                    button.color = primaryColorInactive
                }
                
                for field in [blogTitleField, secondaryPostsField, secondaryFollowersField, secondaryMessagesField, secondaryDraftsField, secondaryQueueField] {
                    field.textColor = secondaryColorInactive
                }
            }
        }
        get {
            return super.backgroundStyle
        }
    }
    
    @IBAction func postsButton(sender: AnyObject!) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://www.tumblr.com/blog/\(blog.name)")!)
    }
    
    @IBAction func followersButton(sender: AnyObject!) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://www.tumblr.com/blog/\(blog.name)/followers")!)
    }
    
    @IBAction func messagesButton(sender: AnyObject!) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://www.tumblr.com/blog/\(blog.name)/messages")!)
    }
    
    @IBAction func draftsButton(sender: AnyObject!) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://www.tumblr.com/blog/\(blog.name)/drafts")!)
    }
    
    @IBAction func queueButton(sender: AnyObject!) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://www.tumblr.com/blog/\(blog.name)/queue")!)
    }
    
}
