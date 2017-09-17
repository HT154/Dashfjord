//
//  APIRequest.swift
//  Treadr
//
//  Created by Joshua Basch on 9/19/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

enum HTTPMethod {
    case get
    case post
}

enum AuthenticationType: String {
    case None
    case Key
    case OAuth
}

enum APICallType {
    case blog(String)
    case user
    case raw
}

class APIRequest<T>: NSObject {
    
    private var task: URLSessionDataTask?
    
    var method = HTTPMethod.get
    var auth = AuthenticationType.OAuth
    var type = APICallType.user
    
    var endpointSuffix: String? = nil
    var endpoint = ""
    var parameters: [String:Any] = [:]
    var callback: ((_ result: T?, _ error: Error?) -> Void)?
    
    var customHeaders: [String:String] = [:]
    
    init(_ endpoint: String) {
        self.endpoint = endpoint
    }
    
    convenience init(_ endpoint: String, blog: String) {
        self.init(endpoint)
        self.type = .blog(blog)
    }
    
    convenience init(_ endpoint: String, parameters: [String:Any]) {
        self.init(endpoint)
        self.parameters = parameters
    }
    
    convenience init(_ endpoint: String, blog: String, parameters: [String:Any]) {
        self.init(endpoint)
        self.type = .blog(blog)
        self.parameters = parameters
    }
    
    convenience init(_ endpoint: String, callback: @escaping (_ result: T?, _ error: Error?) -> Void) {
        self.init(endpoint)
        self.callback = callback
    }
    
    convenience init(_ endpoint: String, blog: String, callback: @escaping (_ result: T?, _ error: Error?) -> Void) {
        self.init(endpoint, blog: blog)
        self.callback = callback
    }
    
    convenience init(_ endpoint: String, parameters: [String:Any], callback: @escaping (_ result: T?, _ error: Error?) -> Void) {
        self.init(endpoint, parameters: parameters)
        self.callback = callback
    }
    
    convenience init(_ endpoint: String, blog: String, parameters: [String:Any], callback: @escaping (_ result: T?, _ error: Error?) -> Void) {
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
        var request = URLRequest(url: URL(string: urlString)!)
        request.setValue("HTTumblrAPI", forHTTPHeaderField: "User-Agent")
        
        if auth == .Key || auth == .OAuth {
            parameters["api_key"] = API.OAuthConsumerKey
        }
        
        if let suffix = endpointSuffix {
            urlString += "/\(suffix)"
        }
        
        switch method {
        case .get:
            request.httpMethod = "GET"
            urlString += "?" + parametersAsString()
        case .post:
            request.httpMethod = "POST"
            
            let bodyData = parametersAsString().replacingOccurrences(of: "%20", with: "+").data(using: String.Encoding.utf8)!
            request.httpBody = bodyData
            
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("\(bodyData.count)", forHTTPHeaderField: "Content-Length")
        }
        
        let url = URL(string: urlString)!
        request.url = url
        
        if auth == .OAuth {
            request.setValue(TMOAuth.header(for: url, method: request.httpMethod, postParameters: parameters, nonce: ProcessInfo.processInfo.globallyUniqueString, consumerKey: API.OAuthConsumerKey, consumerSecret: API.OAuthConsumerSecret, token: API.OAuthToken, tokenSecret: API.OAuthTokenSecret), forHTTPHeaderField: "Authorization")
        }
        
        for (key, value) in customHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        task = API.URLSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil || data == nil {
                    self.callback?(nil, error)
                    return
                }
                
                if T.self == NSImage.self {
                    self.callback?(NSImage(data: data!) as? T, nil)
                } else if T.self == Data.self {
                    self.callback?(data as? T, nil)
                } else {
                    do {
                        let result: T = try JSONSerialization.jsonObject(with: data!, options: []) as! T
                        self.callback?(result, nil)
                    } catch let error {
                        self.callback?(nil, error)
                    }
                }
            }
        }
        task?.resume()
    }
    
    private func parametersAsString() -> String {
        let params = NSMutableArray()
        
        for key in parameters.keys.sorted() {
            addPair(key, value: parameters[key]!, array: params)
        }
        
        return params.componentsJoined(by: "&")
    }
    
    private func addPair(_ key: String, value: Any, array: NSMutableArray) {
        switch parseType(value) {
        case "Array":
            for val in value as! [Any] {
                addPair(key, value: val, array: array)
            }
        case "Dictionary":
            let dict = value as! [String:Any]
            for subKey in dict.keys.sorted() {
                addPair("\(key)[\(subKey)]", value: dict[key]!, array: array)
            }
        default:
            array.add("\(key)=\(encodedString("\(value)")!)")
        }
    }
    
    private func parseType<U>(_ input: U) -> String {
        return ""
    }
    
    private func parseType<U>(_ input: Array<U>) -> String {
        return "Array"
    }
    
    private func parseType<U, V>(_ input: Dictionary<U, V>) -> String {
        return "Dictionary"
    }
    
    private func subURL() -> String {
        switch type {
        case .user:
            return "user/"
        case .blog(let url):
            return "blog/\(API.fullURL(url))/"
        case .raw:
            return ""
        }
    }
    
}
