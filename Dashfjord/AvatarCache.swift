//
//  AvatarCache.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/26/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class AvatarCache: NSObject {

    static let sharedInstance = AvatarCache()
    
    private let cache = NSCache<NSString, NSImage>()
    private var recReq: [NSObject:(APIRequest<NSImage>, String)] = [:]
    private var keyRec: [String:[NSObject]] = [:]
    private var keyReq: [String:APIRequest<NSImage>] = [:]
    private let blankImage = NSImage(named: "blank")!
    private let dummyReceiver = NSObject()
    
    override init() {
        super.init()
        
        cache.name = "AvatarCache"
    }
    
    func loadAvatar(_ blog: String, size: CGFloat, into receiver: NSObject? = nil, imageProcessing: ((NSImage) -> Void)? = nil) {
        var blog = blog
        let receiver: NSObject = receiver ?? dummyReceiver
        
        if let dotIdx = blog.range(of: ".")?.lowerBound {
            blog = blog.substring(to: dotIdx)
        }
        
        let key = "\(blog)_\(Int(size))"
        if let image = cache.object(forKey: key as NSString) {
            putImage(image, into: receiver, imageProcessing: imageProcessing)
            return
        }
        
        if let (currentRequest, prevKey) = recReq[receiver] {
            if key != prevKey {
                currentRequest.cancel()
            } else {
                return
            }
        }
        
        putImage(blankImage, into: receiver, imageProcessing: imageProcessing)
        
        if let req = keyReq[key] {
            keyRec[key]!.append(receiver)
            recReq[receiver] = (req, key)
        } else {
            keyRec[key] = [receiver]
            
            let req = API.avatarRequest(blog, size: size) { (avatar, error) -> Void in
                if let image = avatar {
                    for rec in self.keyRec[key]! {
                        self.putImage(image, into: rec, imageProcessing: imageProcessing)
                    }
                    
                    self.cache.setObject(image, forKey: key as NSString)
                } else {
                    for rec in self.keyRec[key]! {
                        self.putImage(self.blankImage, into: rec, imageProcessing: imageProcessing)
                    }
                    
                    self.cache.removeObject(forKey: key as NSString)
                }
                
                self.keyReq.removeValue(forKey: key)
                self.keyRec.removeValue(forKey: key)
            }
            
            keyReq[key] = req
            recReq[receiver] = (req, key)
            req.send()
        }
    }
    
    private func putImage(_ image: NSImage?, into receiver: NSObject, imageProcessing: ((NSImage) -> Void)?) {
        if image != nil {
            if let processor = imageProcessing {
                processor(image!)
            }
        }
        
        if receiver is NSImageView {
            (receiver as! NSImageView).image = image
        } else if receiver is NSButton {
            (receiver as! NSButton).image = image
        } else if receiver is TrimScaleImageButton {
            (receiver as! TrimScaleImageButton).image = image
        } else if receiver is NSMenuItem {
            (receiver as! NSMenuItem).image = image
        }
    }
    
}
