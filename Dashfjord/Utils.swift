//
//  Utils.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/25/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class Utils: NSObject {
    
    enum DebugMode {
        case Off
        case Blog
        case Post
    }
    
    static let debug = DebugMode.Off
    
    static let tumblrBlue = NSColor(red: (54.0/255), green: (70.0/255), blue: (93.0/255), alpha: 1)
    static let bodyTextColor = NSColor(white: (68.0/255), alpha: 1)
    static let quoteTextColor = NSColor(white: (52.0/255), alpha: 1)
    static let postWidth: CGFloat = 540
    
    class func createTextButton() -> TextTintButton {
        let button = TextTintButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(NSLayoutPriorityRequired, forOrientation: .Horizontal)
        button.alignment = .Center
        button.bordered = false
        button.imagePosition = .NoImage
        
        return button
    }
    
    class func createImageButton() -> RoundRectImageButton {
        let button = RoundRectImageButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bordered = false
        button.imagePosition = .ImageOnly
        (button.cell! as! NSButtonCell).imageScaling = .ScaleAxesIndependently
        
        return button
    }
    
    class func createLabel(font font: NSFont? = nil, textColor: NSColor? = nil) -> NSTextField {
        let label = NSTextField()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.editable = false
        label.selectable = false
        label.allowsEditingTextAttributes = true
        
        label.bordered = false
        label.drawsBackground = false
        
        if let f = font {
            label.font = f
        }
        
        if let c = textColor {
            label.textColor = c
        }
        
        return label
    }
    
    class func createResizingLabel(font font: NSFont? = nil, textColor: NSColor? = nil) -> NSTextField {
        let label = Utils.createLabel(font: font, textColor: textColor)
        
        label.setContentHuggingPriority(249, forOrientation: .Horizontal)
        label.setContentCompressionResistancePriority(249, forOrientation: .Horizontal)
        
        label.selectable = true
        label.lineBreakMode = .ByWordWrapping
        
        return label
    }
    
    class func createPostImageView(tag: Int, width: CGFloat, aspect: CGFloat, target: AnyObject?, action: Selector) -> TrimScaleImageButton {
        let imageView = TrimScaleImageButton()
        imageView.tag = tag
        imageView.target = target
        imageView.action = action
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: width).active = true
        NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Height, multiplier: aspect, constant: 0).active = true
        
        return imageView
    }
    
}

extension NSColor {
    convenience init?(hexString string: String) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        let trimmed = string.stringByReplacingOccurrencesOfString("#", withString: "")
        let scanner = NSScanner(string: trimmed)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexLongLong(&hexValue) {
            switch (trimmed.characters.count) {
            case 3:
                red = CGFloat((hexValue & 0xF00) >> 8) / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4) / 15.0
                blue = CGFloat(hexValue & 0x00F) / 15.0
            case 4:
                red = CGFloat((hexValue & 0xF000) >> 12) / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8) / 15.0
                blue = CGFloat((hexValue & 0x00F0) >> 4) / 15.0
                alpha = CGFloat(hexValue & 0x000F) / 15.0
            case 6:
                red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
                blue = CGFloat(hexValue & 0x0000FF) / 255.0
            case 8:
                red = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
                alpha = CGFloat(hexValue & 0x000000FF) / 255.0
            default: return nil
            }
        } else {
            return nil
        }
        
        self.init(calibratedRed: red, green: green, blue: blue, alpha: alpha)
    }
}

extension String {
    
    func withoutHTMLEntities() -> String {
        return try! NSAttributedString(data: dataUsingEncoding(NSUTF8StringEncoding)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes: nil).string
    }
    
}