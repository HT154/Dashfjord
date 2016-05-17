//
//  Theme.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/24/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

enum AvatarShape: String {
    case Square = "square"
    case Circle = "circle"
}

class Theme: ModelType {

    var avatarShape: AvatarShape?
    var backgroundColor: NSColor
    var bodyFont: String
    var headerBounds: NSRect?
    var headerFocusSize: NSSize?
    var headerFullSize: NSSize?
    var headerImage: String
    var headerImageFocused: String
    var headerImageScaled: String
    var headerStretch: Bool
    var linkColor: NSColor
    var showAvatar: Bool
    var showDescription: Bool
    var showHeaderImage: Bool
    var showTitle: Bool
    var titleColor: NSColor
    var titleFont: String
    var titleFontWeight: String
    
    required init(dict: JSONDict) {
        if let avs = dict["avatar_shape"] as! String? {
            avatarShape = AvatarShape(rawValue: avs)
        }
        
        backgroundColor = NSColor(hexString: dict["background_color"]! as! String)!
        bodyFont = dict["body_font"]! as! String
        
        if dict["header_bounds"] is String {
            let headerComponents = (dict["header_bounds"]! as! String).componentsSeparatedByString(",")
            if headerComponents.count == 4 {
                headerBounds = NSRect(x: Int(headerComponents[0])!, y: Int(headerComponents[1])!, width: Int(headerComponents[2])!, height: Int(headerComponents[3])!)
            }
        }
        
        if dict["header_focus_width"] != nil && dict["header_focus_height"] != nil {
            headerFocusSize = NSSize(width: dict["header_focus_width"]! as! Int, height: dict["header_focus_height"]! as! Int)
        }
        
        if dict["header_focus_width"] != nil && dict["header_focus_height"] != nil {
            headerFullSize = NSSize(width: dict["header_focus_width"]! as! Int, height: dict["header_focus_height"]! as! Int)
        }
        
        headerImage = dict["header_image"]! as! String
        headerImageFocused = dict["header_image_focused"]! as! String
        headerImageScaled = dict["header_image_scaled"]! as! String
        headerStretch = dict["header_stretch"]! as! Bool
        linkColor = NSColor(hexString: dict["link_color"]! as! String)!
        showAvatar = dict["show_avatar"]! as! Bool
        showDescription = dict["show_description"]! as! Bool
        showHeaderImage = dict["show_header_image"]! as! Bool
        showTitle = dict["show_title"]! as! Bool
        titleColor = NSColor(hexString: dict["title_color"]! as! String)!
        titleFont = dict["title_font"]! as! String
        titleFontWeight = dict["title_font_weight"]! as! String
    }
    
}