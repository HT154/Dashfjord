//
//  Font.swift
//  Dashfjord
//
//  Created by Joshua Basch on 11/28/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class Font {
    
    enum Weight: String {
        case Light = "Light"
        case Regular = "Regular"
        case SemiBold = "Medium"
        case Bold = "Bold"
    }
    
    enum Face: String {
        case Body = "HelveticaNeue"
        case Title = "Gibson"
        case Serif = "Georgia"
        case Monospace = "Courier"
    }
    
    class func italicStyle(_ font: Font.Face) -> String {
        switch font {
        case .Monospace: return "Oblique"
        default: return "Italic"
        }
    }
    
    class func get(_ font: Font.Face = .Body, weight: Font.Weight = .Regular, italic: Bool = false, size: CGFloat) -> NSFont {
        var font = font
        if font == .Title {
            font = .Body
        } // Remove when Gibson font is actually available
        
        var name = font.rawValue
        
        if weight != .Regular {
            name += "-\(weight.rawValue)"
            
            if italic {
                name += italicStyle(font)
            }
        } else if italic {
            name += "-\(italicStyle(font))"
        }
        
        return NSFont(name: name, size: size)!
    }
    
    class func printAll() {
        for family in NSFontManager.shared().availableFontFamilies {
            print(family)
            
            if let fonts = NSFontManager.shared().availableMembers(ofFontFamily: family) {
                for font in fonts {
                    print("\t\(font)")
                }
            }
        }
    }
    
}
