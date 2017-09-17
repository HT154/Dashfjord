//
//  API.swift
//  Treadr
//
//  Created by Joshua Basch on 9/19/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

typealias JSONDict = [String:Any]

class API {
    
    static let baseURL = "https://api.tumblr.com/v2/"
    
    static let URLSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
    
    static var OAuthConsumerKey = ""
    static var OAuthConsumerSecret = ""
    static var OAuthToken = ""
    static var OAuthTokenSecret = ""
    
    init?() {
        return nil
    }
    
    // MARK: - Convenience Methods
    // MARK: User
    
    class func info(_ callback: @escaping (_ info: JSONDict?, _ blogs: [Blog]?, _ error: Error?) -> Void) {
        infoRequest(callback).send()
    }
    
    class func dashboard(_ parameters: [String:Any] = [:], callback: @escaping (_ posts: [Post]?, _ error: Error?) -> Void) {
        dashboardRequest(parameters, callback: callback).send()
    }
    
    class func likes(_ parameters: [String:Any] = [:], callback: @escaping (_ count: Int?, _ posts: [Post]?, _ error: Error?) -> Void) {
        likesRequest(parameters, callback: callback).send()
    }
    
    class func following(_ parameters: [String:Any] = [:], callback: @escaping (_ count: Int?, _ following: [Blog]?, _ error: Error?) -> Void) {
        followingRequest(parameters, callback: callback).send()
    }
    
    class func follow(_ blog: String, callback: @escaping (_ error: Error?) -> Void) {
        followRequest(blog, callback: callback).send()
    }
    
    class func unfollow(_ blog: String, callback: @escaping (_ error: Error?) -> Void) {
        unfollowRequest(blog, callback: callback).send()
    }
    
    class func like(_ id: Int, reblogKey: String, callback: @escaping (_ error: Error?) -> Void) {
        likeRequest(id, reblogKey: reblogKey, callback: callback).send()
    }
    
    class func unlike(_ id: Int, reblogKey: String, callback: @escaping (_ error: Error?) -> Void) {
        unlikeRequest(id, reblogKey: reblogKey, callback: callback).send()
    }
    
    // MARK: Blog
    
    class func avatar(blog: String, size: CGFloat, callback: @escaping (_ avatar: NSImage?, _ error: Error?) -> Void) {
        avatarRequest(blog, size: size, callback: callback).send()
    }
    
    // info
    
    // followers
    
    class func posts(blog: String, type: PostType? = nil, parameters: [String:Any] = [:], callback: @escaping (_ posts: [Post]?, _ blog: Blog?, _ error: Error?) -> Void) {
        postsRequest(blog, type: type, parameters: parameters, callback: callback).send()
    }
    
    class func queue(blog: String, parameters: [String:Any] = [:], callback: @escaping (_ posts: [Post]?, _ error: Error?) -> Void) {
        queueRequest(blog, parameters: parameters, callback: callback).send()
    }
    
    class func drafts(blog: String, parameters: [String:Any] = [:], callback: @escaping (_ posts: [Post]?, _ error: Error?) -> Void) {
        draftsRequest(blog, parameters: parameters, callback: callback).send()
    }
    
    // submissions
    
    class func likes(blog: String, parameters: [String:Any] = [:], callback: @escaping (_ count: Int?, _ posts: [Post]?, _ error: Error?) -> Void) {
        likesRequest(blog: blog, parameters: parameters, callback: callback).send()
    }
    
    // MARK: Posting
    
    // post
    
    // edit
    
    class func reblog(_ blog: String, id: Int, reblogKey: String, comment: String? = nil, parameters: [String:Any] = [:], callback: @escaping (_ error: Error?) -> Void) {
        reblogRequest(blog, id: id, reblogKey: reblogKey, comment: comment, parameters: parameters, callback: callback).send()
    }
    
    class func delete(_ blog: String, id: Int, callback: @escaping (_ error: Error?) -> Void) {
        deleteRequest(blog, id: id, callback: callback).send()
    }
    
    // MARK: Tagging
    
    class func tagged(_ tag: String, parameters: [String:Any] = [:], callback: @escaping (_ posts: [Post]?, _ error: Error?) -> Void) {
        taggedRequest(tag, parameters: parameters, callback: callback).send()
    }
    
    // MARK: Private
    
    class func notes(_ blog: String, id: Int, beforeTimestamp: Int? = nil, callback: @escaping (_ notes: [Note]?, _ error: Error?) -> Void) {
        notesRequest(blog, id: id, beforeTimestamp: beforeTimestamp, callback: callback).send()
    }
    
    // MARK: - Request Methods
    // MARK: User
    
    class func infoRequest(_ callback: @escaping (_ info: [String:Any]?, _ blogs: [Blog]?, _ error: Error?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("info") { (result: JSONDict?, error: Error?) in
            if let error = collateErrors(result, error) {
                callback(nil, nil, error)
            } else if let response = result?["response"] as? JSONDict {
                var info = response["user"]! as! JSONDict
                let blogs: [Blog] = modelize(info["blogs"]! as! [JSONDict])
                info.removeValue(forKey: "blogs")
                
                callback(info, blogs, nil)
            }
        }
        
        return request
    }
    
    class func dashboardRequest(_ parameters: [String:Any] = [:], callback: @escaping (_ posts: [Post]?, _ error: Error?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("dashboard", parameters: parameters) { (result: JSONDict?, error: Error?) in
            if let error = collateErrors(result, error) {
                callback(nil, error)
            } else if let response = result?["response"] as? JSONDict {
                let posts: [Post] = modelize(response["posts"]! as! [JSONDict])
                
                callback(posts, nil)
            }
        }
        
        return request
    }
    
    class func likesRequest(_ parameters: [String:Any] = [:], callback: @escaping (_ count: Int?, _ posts: [Post]?, _ error: Error?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("likes", parameters:  parameters) { (result: JSONDict?, error: Error?) in
            if let error = collateErrors(result, error) {
                callback(nil, nil, error)
            } else if let response = result?["response"] as? JSONDict {
                let count = response["liked_count"]! as? Int
                let posts: [Post] = modelize(response["liked_posts"]! as! [JSONDict])
                
                callback(count, posts, nil)
            }
        }
        
        return request
    }
    
    class func followingRequest(_ parameters: [String:Any] = [:], callback: @escaping (_ count: Int?, _ following: [Blog]?, _ error: Error?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("following", parameters: parameters) { (result: JSONDict?, error: Error?) in
            if let error = collateErrors(result, error) {
                callback(nil, nil, error)
            } else if let response = result?["response"] as? JSONDict {
                let count = response["total_blogs"] as? Int
                let following: [Blog] = modelize(response["blogs"] as! [JSONDict])
                
                callback(count, following, nil)
            }
        }
        
        return request
    }
    
    class func followRequest(_ blog: String, callback: @escaping (_ error: Error?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("follow", parameters: ["url": fullURL(blog)]) { (result: JSONDict?, error: Error?) in
            callback(collateErrors(result, error))
        }
        request.method = .post
        
        return request
    }
    
    class func unfollowRequest(_ blog: String, callback: @escaping (_ error: Error?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("unfollow", parameters: ["url": fullURL(blog)]) { (result: JSONDict?, error: Error?) in
            callback(collateErrors(result, error))
        }
        request.method = .post
        
        return request
    }
    
    class func likeRequest(_ id: Int, reblogKey: String, callback: @escaping (_ error: Error?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("like", parameters: ["id": id, "reblog_key": reblogKey]) { (result: JSONDict?, error: Error?) in
            callback(collateErrors(result, error))
        }
        request.method = .post
        
        return request
    }
    
    class func unlikeRequest(_ id: Int, reblogKey: String, callback: @escaping (_ error: Error?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("unlike", parameters: ["id": id, "reblog_key": reblogKey]) { (result: JSONDict?, error: Error?) in
            callback(collateErrors(result, error))
        }
        request.method = .post
        
        return request
    }
    
    // MARK: Blog
    
    class func avatarRequest(_ blog: String, size: CGFloat, callback: @escaping (_ avatar: NSImage?, _ error: Error?) -> Void) -> APIRequest<NSImage> {
        let request = APIRequest("avatar", blog: blog, parameters: ["size": size], callback: callback)
        
        return request
    }
    
    // infoRequest
    
    // followersRequest
    
    class func postsRequest(_ blog: String, type: PostType? = nil, parameters: [String:Any] = [:], callback: @escaping (_ posts: [Post]?, _ blog: Blog?, _ error: Error?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("posts", blog: blog, parameters: parameters) { (result: JSONDict?, error: Error?) in
            if let error = collateErrors(result, error) {
                callback(nil, nil, error)
            } else if let response = result?["response"] as? JSONDict {
                let posts: [Post] = modelize(response["posts"]! as! [JSONDict])
                let blog: Blog = modelizeSingle(response["blog"]! as! JSONDict)
                
                callback(posts, blog, nil)
            }
        }
        
        if let postType = type {
            request.endpointSuffix = postType.rawValue
        }
        
        return request
    }
    
    class func queueRequest(_ blog: String, parameters: [String:Any] = [:], callback: @escaping (_ posts: [Post]?, _ error: Error?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("posts/queue", blog: blog, parameters: parameters) { (result: JSONDict?, error: Error?) in
            if let error = collateErrors(result, error) {
                callback(nil, error)
            } else if let response = result?["response"] as? JSONDict {
                let posts: [Post] = modelize(response["posts"]! as! [JSONDict])
                
                callback(posts, nil)
            }
        }
        
        return request
    }
    
    class func draftsRequest(_ blog: String, parameters: [String:Any] = [:], callback: @escaping (_ posts: [Post]?, _ error: Error?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("posts/draft", blog: blog, parameters: parameters) { (result: JSONDict?, error: Error?) in
            if let error = collateErrors(result, error) {
                callback(nil, error)
            } else if let response = result?["response"] as? JSONDict {
                let posts: [Post] = modelize(response["posts"]! as! [JSONDict])
                
                callback(posts, nil)
            }
        }
        
        return request
    }
    
    // submissionsRequest
    
    class func likesRequest(blog: String, parameters: [String:Any] = [:], callback: @escaping (_ count: Int?, _ posts: [Post]?, _ error: Error?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("likes", blog: blog, parameters: parameters) { (result: JSONDict?, error: Error?) in
            if let error = collateErrors(result, error) {
                callback(nil, nil, error)
            } else if let response = result?["response"] as? JSONDict {
                let count = response["liked_count"]! as? Int
                let posts: [Post] = modelize(response["liked_posts"]! as! [JSONDict])
                
                callback(count, posts, nil)
            }
        }
        
        return request
    }
    
    // MARK: Posting
    
    // postRequest
    
    // editRequest
    
    class func reblogRequest(_ blog: String, id: Int, reblogKey: String, comment: String?, parameters: [String:Any], callback: @escaping (_ error: Error?) -> Void) ->
        APIRequest<JSONDict> {
            var parameters = parameters
            parameters["id"] = id
            parameters["reblog_key"] = reblogKey
            
            if let c = comment {
                parameters["comment"] = c
            }
            
            let request = APIRequest("post/reblog", blog: blog, parameters: parameters) { (result: JSONDict?, error: Error?) in
                callback(collateErrors(result, error))
            }
            request.method = .post
            
            return request
    }
    
    class func deleteRequest(_ blog: String, id: Int, callback: @escaping (_ error: Error?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("post/delete", blog: blog, parameters: ["id": id]) { (result: JSONDict?, error: Error?) in
            callback(collateErrors(result, error))
        }
        request.method = .post
        
        return request
    }
    
    // MARK: Tagging
    
    class func taggedRequest(_ tag: String, parameters: [String:Any], callback: @escaping (_ posts: [Post]?, _ error: Error?) -> Void) -> APIRequest<JSONDict> {
        var parameters = parameters
        parameters["tag"] = tag
        
        let request = APIRequest("tagged", parameters: parameters) { (result: JSONDict?, error: Error?) in
            if let error = collateErrors(result, error) {
                callback(nil, error)
            } else if let response = result?["response"] {
                let posts: [Post] = modelize(response as! [JSONDict])
                
                callback(posts, nil)
            }
        }
        request.type = .raw
        
        return request
    }
    
    // MARK: Private
    
    class func notesRequest(_ blog: String, id: Int, beforeTimestamp: Int?, callback: @escaping (_ notes: [Note]?, _ error: Error?) -> Void) -> APIRequest<JSONDict> {
        var parameters: [String:Any] = ["id": id]
        if let timestamp = beforeTimestamp {
            parameters["before_timestamp"] = timestamp
        }
        
        let request = APIRequest("notes", blog: blog, parameters: parameters) { (result: JSONDict?, error: Error?) in
            if let error = collateErrors(result, error) {
                callback(nil, error)
            } else if let response = result?["response"] as? JSONDict {
                let notes: [Note] = modelize(response["notes"]! as! [JSONDict])
                
                callback(notes, nil)
            }
        }
        
        return request
    }
    
    // MARK: - Utilities
    
    class func fullURL(_ blog: String) -> String {
        if blog.contains(".") {
            return blog
        }
        
        return "\(blog).tumblr.com"
    }
    
    class func collateErrors(_ result: JSONDict?, _ error: Error?) -> Error? {
        if error != nil { return error }
        
        if let meta = result?["meta"] as! JSONDict? {
            if (meta["status"] as! Int) / 100 != 2 {
                return NSError(domain: "HTTumblrAPIError", code: meta["status"] as! Int, userInfo: [NSLocalizedDescriptionKey: meta["msg"] as! String])
            }
        } else {
            return NSError(domain: "HTTumblrAPIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occured"])
        }
        
        return nil
    }
    
}
