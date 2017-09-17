//
//  Photo.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/20/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class Photo: NSObject, ModelType {
    
    var URL: String
    var width: Int
    var height: Int
    var caption: String
    var altSizes: [[String:AnyObject]]
    
    var aspectRatio: CGFloat {
        get {
            let aspect = CGFloat(width) / CGFloat(height)
            
            if aspect != aspect {
                return 1
            }
            
            return aspect
        }
    }
    
    required init(dict: JSONDict) {
        URL = (dict["original_size"] as! JSONDict)["url"]! as! String
        width = (dict["original_size"] as! JSONDict)["width"]! as! Int
        height = (dict["original_size"] as! JSONDict)["height"]! as! Int
        caption = dict["caption"]! as! String
        altSizes = dict["alt_sizes"]! as! [[String:AnyObject]]
    }
    
    func URLAppropriateForWidth(_ width: CGFloat) -> String {
        if altSizes.count == 0 {
            return URL
        }
        
        var i = 0
        
        while i < altSizes.count {
            if CGFloat(altSizes[i]["width"] as! Int) <= width {
                break
            }
            
            i += 1
        }
        
        i -= 1
        
        return altSizes[max(i, 0)]["url"] as! String
    }
    
}
