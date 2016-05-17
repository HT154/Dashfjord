//
//  QuestionView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/1/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class QuestionView: NSView {

    var askingName: String! {
        didSet {
            if askingName != nil {
                if askingName != "Anonymous"  {
                    blogButton.enabled = true
                    avatarButton.enabled = true
                    
                    AvatarCache.sharedInstance.loadAvatar(askingName, size: 64, into: avatarButton)
                } else {
                    blogButton.enabled = false
                    avatarButton.enabled = false
                    
                    PhotoCache.sharedInstance.loadURL("https://secure.assets.tumblr.com/images/anonymous_avatar_64.gif", into: avatarButton)
                }
                
                let blogString = NSMutableAttributedString(string: "\(askingName) said", attributes: [NSFontAttributeName: Font.get(size: 13), NSForegroundColorAttributeName: NSColor(white: (166.0/255), alpha: 1)])
                blogString.addAttribute(NSFontAttributeName, value: Font.get(weight: .Bold, size: 13), range: NSMakeRange(0, askingName.characters.count))
                
                if askingName != "Anonymous" {
                    blogString.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: NSMakeRange(0, askingName.characters.count))
                }
                
                blogButton.attributedTitle = blogString
            }
        }
    }
    
    var askingURL: String!
    
    var question: String! {
        didSet {
            if question != nil {
                questionField.stringValue = question
            }
        }
    }
    
    private var questionField: NSTextField = {
        let field = Utils.createResizingLabel()
        field.drawsBackground = false
        field.font = Font.get(size: 14)
        
        return field
    }()
    
    private var blogButton: NSButton = {
        let button = Utils.createTextButton()
        button.action = #selector(QuestionView.openAskingURL(_:))
        
        return button
    }()
    
    private var avatarButton: NSButton = {
        let button = Utils.createImageButton()
        (button.cell as? NSButtonCell)?.imageDimsWhenDisabled = false
        button.action = #selector(QuestionView.openAskingURL(_:))
        
        return button
    }()

    let avatarSize: CGFloat = 32
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    init() {
        super.init(frame: NSZeroRect)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        blogButton.target = self
        avatarButton.target = self
        
        addSubview(questionField)
        addSubview(blogButton)
        addSubview(avatarButton)
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[blogButton]", options: [], metrics: nil, views: ["blogButton": blogButton]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[questionField]-\(avatarSize + 20)-|", options: [], metrics: nil, views: ["questionField": questionField]))
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[blogButton]-10-[questionField]-10-|", options: [], metrics: nil, views: ["blogButton": blogButton, "questionField": questionField]))
        
        NSLayoutConstraint(item: avatarButton, attribute: .Width, relatedBy: .Equal, toItem: avatarButton, attribute: .Height, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[avatarButton(\(avatarSize))]-0-|", options: [], metrics: nil, views: ["avatarButton": avatarButton]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[avatarButton]", options: [], metrics: nil, views: ["avatarButton": avatarButton]))
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        NSColor(calibratedWhite: (245.0/255), alpha: 1.0).setFill()
        NSColor(calibratedWhite: (217.0/255), alpha: 1.0).setStroke()
        
        var boxFrame = bounds
        boxFrame.size.width -= (avatarSize + 10)
        let boxPath = NSBezierPath(roundedRect: boxFrame, xRadius: 2, yRadius: 2)
        boxPath.fill()
        boxPath.stroke()
        
        let arrowPath = NSBezierPath()
        arrowPath.moveToPoint(NSPoint(x: boxFrame.size.width, y: boxFrame.size.height - 10))
        arrowPath.lineToPoint(NSPoint(x: boxFrame.size.width + 5, y: boxFrame.size.height - 15))
        arrowPath.lineToPoint(NSPoint(x: boxFrame.size.width, y: boxFrame.size.height - 20))
        arrowPath.stroke()
        arrowPath.lineToPoint(NSPoint(x: boxFrame.size.width - 2, y: boxFrame.size.height - 20))
        arrowPath.lineToPoint(NSPoint(x: boxFrame.size.width - 2, y: boxFrame.size.height - 10))
        arrowPath.closePath()
        arrowPath.fill()
    }
    
    @IBAction func openAskingURL(sender: AnyObject!) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: askingURL)!)
    }
    
}
