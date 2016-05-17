//
//  PhotoCache.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/26/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PhotoCache {

    static let sharedInstance = PhotoCache()
    
    private let cache = NSCache()
    private let URLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    private var recReq: [NSObject:(NSURLSessionDataTask, String)] = [:]
    private var keyRec: [String:[NSObject]] = [:]
    private var keyReq: [String:NSURLSessionDataTask] = [:]
    
    init() {
        cache.name = "PhotoCache"
    }
    
    func loadURL(URL: String, into receiver: NSObject) {
        if let image = cache.objectForKey(URL) as? NSImage {
            putImage(image, into: receiver)
            return
        }
        
        if let (currentRequest, prevURL) = recReq[receiver] {
            if URL != prevURL {
                currentRequest.cancel()
            } else {
                return
            }
        }
        
        putImage(nil, into: receiver)
        
        if let req = keyReq[URL] {
            keyRec[URL]!.append(receiver)
            recReq[receiver] = (req, URL)
        } else {
            keyRec[URL] = [receiver]
            
            let properURL = NSURL(string: URL.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!
            
            let request = NSURLRequest(URL: properURL, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 30)
            let task = URLSession.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
                dispatch_async(dispatch_get_main_queue()) {
                    if let result = data {
                        let image = NSImage(data: result)
                        
                        for rec in self.keyRec[URL]! {
                            self.putImage(image, into: rec)
                        }
                        
                        if image != nil {
                            self.cache.setObject(image!, forKey: URL)
                        }
                    } else {
                        for rec in self.keyRec[URL]! {
                            self.putImage(nil, into: rec)
                        }
                        
                        self.cache.removeObjectForKey(URL)
                    }
                    
                    self.keyReq.removeValueForKey(URL)
                    self.keyRec.removeValueForKey(URL)
                }
            }
            
            keyReq[URL] = task
            recReq[receiver] = (task, URL)
            task.resume()
        }
    }
    
    private func putImage(image: NSImage?, into receiver: NSObject) {
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
