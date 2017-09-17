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
    
    private let cache = NSCache<NSString, NSImage>()
    private let URLSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
    private var recReq: [NSObject:(URLSessionDataTask, String)] = [:]
    private var keyRec: [String:[NSObject]] = [:]
    private var keyReq: [String:URLSessionDataTask] = [:]
    
    init() {
        cache.name = "PhotoCache"
    }
    
    func loadURL(_ URL: String, into receiver: NSObject) {
        if let image = cache.object(forKey: URL as NSString) {
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
            
            let properURL = Foundation.URL(string: URL.replacingOccurrences(of: "http://", with: "https://"))!
            
            let request = URLRequest(url: properURL, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 30)
            let task = URLSession.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                DispatchQueue.main.async {
                    if let result = data {
                        let image = NSImage(data: result)
                        
                        for rec in self.keyRec[URL]! {
                            self.putImage(image, into: rec)
                        }
                        
                        if image != nil {
                            self.cache.setObject(image!, forKey: URL as NSString)
                        }
                    } else {
                        for rec in self.keyRec[URL]! {
                            self.putImage(nil, into: rec)
                        }
                        
                        self.cache.removeObject(forKey: URL as NSString)
                    }
                    
                    self.keyReq.removeValue(forKey: URL)
                    self.keyRec.removeValue(forKey: URL)
                }
            }
            
            keyReq[URL] = task
            recReq[receiver] = (task, URL)
            task.resume()
        }
    }
    
    private func putImage(_ image: NSImage?, into receiver: NSObject) {
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
