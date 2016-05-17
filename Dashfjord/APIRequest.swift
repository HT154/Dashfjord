//
//  APIRequest.swift
//  Treadr
//
//  Created by Joshua Basch on 9/19/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

enum HTTPMethod {
    case Get
    case Post
}

enum AuthenticationType: String {
    case None
    case Key
    case OAuth
}

enum APICallType {
    case Blog(String)
    case User
    case Raw
}

class APIRequest<T>: NSObject {
    
    private var task: NSURLSessionDataTask?
    
    var method = HTTPMethod.Get
    var auth = AuthenticationType.OAuth
    var type = APICallType.User
    
    var endpointSuffix: String? = nil
    var endpoint = ""
    var parameters: [String:AnyObject] = [:]
    var callback: ((result: T?, error: NSError?) -> Void)?
    
    var customHeaders: [String:String] = [:]
    
    init(_ endpoint: String) {
        self.endpoint = endpoint
    }
    
    convenience init(_ endpoint: String, blog: String) {
        self.init(endpoint)
        self.type = .Blog(blog)
    }
    
    convenience init(_ endpoint: String, parameters: [String:AnyObject]) {
        self.init(endpoint)
        self.parameters = parameters
    }
    
    convenience init(_ endpoint: String, blog: String, parameters: [String:AnyObject]) {
        self.init(endpoint)
        self.type = .Blog(blog)
        self.parameters = parameters
    }
    
    convenience init(_ endpoint: String, callback: (result: T?, error: NSError?) -> Void) {
        self.init(endpoint)
        self.callback = callback
    }
    
    convenience init(_ endpoint: String, blog: String, callback: (result: T?, error: NSError?) -> Void) {
        self.init(endpoint, blog: blog)
        self.callback = callback
    }
    
    convenience init(_ endpoint: String, parameters: [String:AnyObject], callback: (result: T?, error: NSError?) -> Void) {
        self.init(endpoint, parameters: parameters)
        self.callback = callback
    }
    
    convenience init(_ endpoint: String, blog: String, parameters: [String:AnyObject], callback: (result: T?, error: NSError?) -> Void) {
        self.init(endpoint, blog: blog, parameters: parameters)
        self.callback = callback
    }
    
    func cancel() {
        task?.cancel()
    }
    
    func send() {
        if endpoint == "" {
            NSLog("Invalid API endpoint")
            return
        }
        
        var urlString = API.baseURL + subURL() + endpoint
        let request = NSMutableURLRequest()
        request.setValue("HTTumblrAPI", forHTTPHeaderField: "User-Agent")
        
        if auth == .Key || auth == .OAuth {
            parameters["api_key"] = API.OAuthConsumerKey
        }
        
        if let suffix = endpointSuffix {
            urlString += "/\(suffix)"
        }
        
        switch method {
        case .Get:
            request.HTTPMethod = "GET"
            urlString += "?" + parametersAsString()
        case .Post:
            request.HTTPMethod = "POST"
            
            let bodyData = parametersAsString().stringByReplacingOccurrencesOfString("%20", withString: "+").dataUsingEncoding(NSUTF8StringEncoding)!
            request.HTTPBody = bodyData
            
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("\(bodyData.length)", forHTTPHeaderField: "Content-Length")
        }
        
        let url = NSURL(string: urlString)!
        request.URL = url
        
        if auth == .OAuth {
            request.setValue(TMOAuth.headerForURL(url, method: request.HTTPMethod, postParameters: parameters, nonce: NSProcessInfo.processInfo().globallyUniqueString, consumerKey: API.OAuthConsumerKey, consumerSecret: API.OAuthConsumerSecret, token: API.OAuthToken, tokenSecret: API.OAuthTokenSecret), forHTTPHeaderField: "Authorization")
        }
        
        for (key, value) in customHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        task = API.URLSession.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil || data == nil {
                    self.callback?(result: nil, error: error)
                    return
                }
                
                if T.self == NSImage.self {
                    self.callback?(result: NSImage(data: data!) as? T, error: nil)
                } else if T.self == NSData.self {
                    self.callback?(result: data as? T, error: nil)
                } else {
                    do {
                        let result: T = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! T
                        self.callback?(result: result, error: nil)
                    } catch let error as NSError {
                        self.callback?(result: nil, error: error)
                    }
                }
            }
        }
        task?.resume()
    }
    
    private func parametersAsString() -> String {
        let params = NSMutableArray()
        
        for key in parameters.keys.sort() {
            addPair(key, value: parameters[key]!, array: params)
        }
        
        return params.componentsJoinedByString("&")
    }
    
    private func addPair(key: String, value: AnyObject, array: NSMutableArray) {
        switch parseType(value) {
        case "Array":
            for val in value as! [AnyObject] {
                addPair(key, value: val, array: array)
            }
        case "Dictionary":
            let dict = value as! [String:AnyObject]
            for subKey in dict.keys.sort() {
                addPair("\(key)[\(subKey)]", value: dict[key]!, array: array)
            }
        default:
            let val = encodedString("\(value)")
            array.addObject("\(key)=\(val)")
        }
    }
    
    private func parseType<U>(input: U) -> String {
        return ""
    }
    
    private func parseType<U>(input: Array<U>) -> String {
        return "Array"
    }
    
    private func parseType<U, V>(input: Dictionary<U, V>) -> String {
        return "Dictionary"
    }
    
    private func subURL() -> String {
        switch type {
        case .User:
            return "user/"
        case .Blog(let url):
            return "blog/\(API.fullURL(url))/"
        case .Raw:
            return ""
        }
    }
    
}