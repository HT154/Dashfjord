//
//  NoteTableCellView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/8/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class NoteTableCellView: NSTableCellView {

    @IBOutlet var avatarImageView: NSImageView!
    @IBOutlet var actionView: ActionView!
    @IBOutlet var noteLabel: NSTextField!
    
    var note: Note! {
        didSet {
            if note != nil {
                actionView.setType(note.type)
                
                var rawStr = "\(note.blogName) \(note.pastTenseVerb) this"
                if let text = note.text {
                    rawStr += ":\n  \"\(text)\""
                }
                
                let str = NSMutableAttributedString(string: rawStr)
                str.addAttribute(NSFontAttributeName, value: Font.get(weight: .Bold, size: 13), range: NSMakeRange(0, note.blogName.characters.count))
                noteLabel.attributedStringValue = str
                
                AvatarCache.sharedInstance.loadAvatar(note.blogName, size: 48, into: avatarImageView)
                
                toolTip = note.text
            }
        }
    }
    
    override var backgroundStyle: NSBackgroundStyle {
        set {
            super.backgroundStyle = newValue
            
            if newValue == .dark {
                noteLabel.textColor = NSColor.white
            } else {
                noteLabel.textColor = NSColor.black
            }
        }
        get { return super.backgroundStyle }
    }
    
}
