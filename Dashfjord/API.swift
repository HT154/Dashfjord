//
//  API.swift
//  Treadr
//
//  Created by Joshua Basch on 9/19/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

typealias JSONDict = [String:AnyObject]

class API {
    
    static let baseURL = "https://api.tumblr.com/v2/"
    
    static let URLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    static var OAuthConsumerKey = ""
    static var OAuthConsumerSecret = ""
    static var OAuthToken = ""
    static var OAuthTokenSecret = ""
    
    init?() {
        return nil
    }
    
    // MARK: - Convenience Methods
    // MARK: User
    
    class func info(callback: (info: JSONDict?, blogs: [Blog]?, error: NSError?) -> Void) {
        infoRequest(callback).send()
    }
    
    class func dashboard(parameters: [String:AnyObject] = [:], callback: (posts: [Post]?, error: NSError?) -> Void) {
        dashboardRequest(parameters, callback: callback).send()
    }
    
    class func likes(parameters: [String:AnyObject] = [:], callback: (count: Int?, posts: [Post]?, error: NSError?) -> Void) {
        likesRequest(parameters, callback: callback).send()
    }
    
    class func following(parameters: [String:AnyObject] = [:], callback: (count: Int?, following: [Blog]?, error: NSError?) -> Void) {
        followingRequest(parameters, callback: callback).send()
    }
    
    class func follow(blog: String, callback: (error: NSError?) -> Void) {
        followRequest(blog, callback: callback).send()
    }
    
    class func unfollow(blog: String, callback: (error: NSError?) -> Void) {
        unfollowRequest(blog, callback: callback).send()
    }
    
    class func like(id: Int, reblogKey: String, callback: (error: NSError?) -> Void) {
        likeRequest(id, reblogKey: reblogKey, callback: callback).send()
    }
    
    class func unlike(id: Int, reblogKey: String, callback: (error: NSError?) -> Void) {
        unlikeRequest(id, reblogKey: reblogKey, callback: callback).send()
    }
    
    // MARK: Blog
    
    class func avatar(blog blog: String, size: CGFloat, callback: (avatar: NSImage?, error: NSError?) -> Void) {
        avatarRequest(blog, size: size, callback: callback).send()
    }
    
    // info
    
    // followers
    
    class func posts(blog blog: String, type: PostType? = nil, parameters: [String:AnyObject] = [:], callback: (posts: [Post]?, blog: Blog?, error: NSError?) -> Void) {
        postsRequest(blog, type: type, parameters: parameters, callback: callback).send()
    }
    
    class func queue(blog blog: String, parameters: [String:AnyObject] = [:], callback: (posts: [Post]?, error: NSError?) -> Void) {
        queueRequest(blog, parameters: parameters, callback: callback).send()
    }
    
    class func drafts(blog blog: String, parameters: [String:AnyObject] = [:], callback: (posts: [Post]?, error: NSError?) -> Void) {
        draftsRequest(blog, parameters: parameters, callback: callback).send()
    }
    
    // submissions
    
    class func likes(blog blog: String, parameters: [String:AnyObject] = [:], callback: (count: Int?, posts: [Post]?, error: NSError?) -> Void) {
        likesRequest(blog: blog, parameters: parameters, callback: callback).send()
    }
    
    // MARK: Posting
    
    // post
    
    // edit
    
    class func reblog(blog: String, id: Int, reblogKey: String, comment: String? = nil, parameters: [String:AnyObject] = [:], callback: (error: NSError?) -> Void) {
        reblogRequest(blog, id: id, reblogKey: reblogKey, comment: comment, parameters: parameters, callback: callback).send()
    }
    
    class func delete(blog: String, id: Int, callback: (error: NSError?) -> Void) {
        deleteRequest(blog, id: id, callback: callback).send()
    }
    
    // MARK: Tagging
    
    class func tagged(tag: String, parameters: [String:AnyObject] = [:], callback: (posts: [Post]?, error: NSError?) -> Void) {
        taggedRequest(tag, parameters: parameters, callback: callback).send()
    }
    
    // MARK: Private
    
    class func notes(blog: String, id: Int, beforeTimestamp: Int? = nil, callback: (notes: [Note]?, error: NSError?) -> Void) {
        notesRequest(blog, id: id, beforeTimestamp: beforeTimestamp, callback: callback).send()
    }
    
    // MARK: - Request Methods
    // MARK: User
    
    class func infoRequest(callback: (info: [String:AnyObject]?, blogs: [Blog]?, error: NSError?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("info") { (result: JSONDict?, error: NSError?) in
            if let error = collateErrors(result, error) {
                callback(info: nil, blogs: nil, error: error)
            } else if let response = result?["response"] {
                var info = response["user"]! as! JSONDict
                let blogs: [Blog] = modelize(info["blogs"]! as! [JSONDict])
                info.removeValueForKey("blogs")
                
                callback(info: info, blogs: blogs, error: nil)
            }
        }
        
        return request
    }
    
    class func dashboardRequest(parameters: [String:AnyObject] = [:], callback: (posts: [Post]?, error: NSError?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("dashboard", parameters: parameters) { (result: JSONDict?, error: NSError?) in
            if let error = collateErrors(result, error) {
                callback(posts: nil, error: error)
            } else if let response = result?["response"] {
                let posts: [Post] = modelize(response["posts"]! as! [JSONDict])
                
                callback(posts: posts, error: nil)
            }
        }
        
        return request
    }
    
    class func likesRequest(parameters: [String:AnyObject] = [:], callback: (count: Int?, posts: [Post]?, error: NSError?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("likes", parameters:  parameters) { (result: JSONDict?, error: NSError?) in
            if let error = collateErrors(result, error) {
                callback(count: nil, posts: nil, error: error)
            } else if let response = result?["response"] {
                let count = response["liked_count"]! as? Int
                let posts: [Post] = modelize(response["liked_posts"]! as! [JSONDict])
                
                callback(count: count, posts: posts, error: nil)
            }
        }
        
        return request
    }
    
    class func followingRequest(parameters: [String:AnyObject] = [:], callback: (count: Int?, following: [Blog]?, error: NSError?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("following", parameters: parameters) { (result: JSONDict?, error: NSError?) in
            if let error = collateErrors(result, error) {
                callback(count: nil, following: nil, error: error)
            } else if let response = result?["response"] {
                let count = response["total_blogs"] as? Int
                let following: [Blog] = modelize(response["blogs"] as! [JSONDict])
                
                callback(count: count, following: following, error: nil)
            }
        }
        
        return request
    }
    
    class func followRequest(blog: String, callback: (error: NSError?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("follow", parameters: ["url": fullURL(blog)]) { (result: JSONDict?, error: NSError?) in
            callback(error: collateErrors(result, error))
        }
        request.method = .Post
        
        return request
    }
    
    class func unfollowRequest(blog: String, callback: (error: NSError?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("unfollow", parameters: ["url": fullURL(blog)]) { (result: JSONDict?, error: NSError?) in
            callback(error: collateErrors(result, error))
        }
        request.method = .Post
        
        return request
    }
    
    class func likeRequest(id: Int, reblogKey: String, callback: (error: NSError?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("like", parameters: ["id": id, "reblog_key": reblogKey]) { (result: JSONDict?, error: NSError?) in
            callback(error: collateErrors(result, error))
        }
        request.method = .Post
        
        return request
    }
    
    class func unlikeRequest(id: Int, reblogKey: String, callback: (error: NSError?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("unlike", parameters: ["id": id, "reblog_key": reblogKey]) { (result: JSONDict?, error: NSError?) in
            callback(error: collateErrors(result, error))
        }
        request.method = .Post
        
        return request
    }
    
    // MARK: Blog
    
    class func avatarRequest(blog: String, size: CGFloat, callback: (avatar: NSImage?, error: NSError?) -> Void) -> APIRequest<NSImage> {
        let request = APIRequest("avatar", blog: blog, parameters: ["size": size], callback: callback)
        
        return request
    }
    
    // infoRequest
    
    // followersRequest
    
    class func postsRequest(blog: String, type: PostType? = nil, parameters: [String:AnyObject] = [:], callback: (posts: [Post]?, blog: Blog?, error: NSError?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("posts", blog: blog, parameters: parameters) { (result: JSONDict?, error: NSError?) in
            if let error = collateErrors(result, error) {
                callback(posts: nil, blog: nil, error: error)
            } else if let response = result?["response"] {
                let posts: [Post] = modelize(response["posts"]! as! [JSONDict])
                let blog: Blog = modelizeSingle(response["blog"]! as! JSONDict)
                
                callback(posts: posts, blog: blog, error: nil)
            }
        }
        
        if let postType = type {
            request.endpointSuffix = postType.rawValue
        }
        
        return request
    }
    
    class func queueRequest(blog: String, parameters: [String:AnyObject] = [:], callback: (posts: [Post]?, error: NSError?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("posts/queue", blog: blog, parameters: parameters) { (result: JSONDict?, error: NSError?) in
            if let error = collateErrors(result, error) {
                callback(posts: nil, error: error)
            } else if let response = result?["response"] {
                let posts: [Post] = modelize(response["posts"]! as! [JSONDict])
                
                callback(posts: posts, error: nil)
            }
        }
        
        return request
    }
    
    class func draftsRequest(blog: String, parameters: [String:AnyObject] = [:], callback: (posts: [Post]?, error: NSError?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("posts/draft", blog: blog, parameters: parameters) { (result: JSONDict?, error: NSError?) in
            if let error = collateErrors(result, error) {
                callback(posts: nil, error: error)
            } else if let response = result?["response"] {
                let posts: [Post] = modelize(response["posts"]! as! [JSONDict])
                
                callback(posts: posts, error: nil)
            }
        }
        
        return request
    }
    
    // submissionsRequest
    
    class func likesRequest(blog blog: String, parameters: [String:AnyObject] = [:], callback: (count: Int?, posts: [Post]?, error: NSError?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("likes", blog: blog, parameters: parameters) { (result: JSONDict?, error: NSError?) in
            if let error = collateErrors(result, error) {
                callback(count: nil, posts: nil, error: error)
            } else if let response = result?["response"] {
                let count = response["liked_count"]! as? Int
                let posts: [Post] = modelize(response["liked_posts"]! as! [JSONDict])
                
                callback(count: count, posts: posts, error: nil)
            }
        }
        
        return request
    }
    
    // MARK: Posting
    
    // postRequest
    
    // editRequest
    
    class func reblogRequest(blog: String, id: Int, reblogKey: String, comment: String?, parameters: [String:AnyObject], callback: (error: NSError?) -> Void) ->
        APIRequest<JSONDict> {
            var parameters = parameters
            parameters["id"] = id
            parameters["reblog_key"] = reblogKey
            
            if let c = comment {
                parameters["comment"] = c
            }
            
            let request = APIRequest("post/reblog", blog: blog, parameters: parameters) { (result: JSONDict?, error: NSError?) in
                callback(error: collateErrors(result, error))
            }
            request.method = .Post
            
            return request
    }
    
    class func deleteRequest(blog: String, id: Int, callback: (error: NSError?) -> Void) -> APIRequest<JSONDict> {
        let request = APIRequest("post/delete", blog: blog, parameters: ["id": id]) { (result: JSONDict?, error: NSError?) in
            callback(error: collateErrors(result, error))
        }
        request.method = .Post
        
        return request
    }
    
    // MARK: Tagging
    
    class func taggedRequest(tag: String, parameters: [String:AnyObject], callback: (posts: [Post]?, error: NSError?) -> Void) -> APIRequest<JSONDict> {
        var parameters = parameters
        parameters["tag"] = tag
        
        let request = APIRequest("tagged", parameters: parameters) { (result: JSONDict?, error: NSError?) in
            if let error = collateErrors(result, error) {
                callback(posts: nil, error: error)
            } else if let response = result?["response"] {
                let posts: [Post] = modelize(response as! [JSONDict])
                
                callback(posts: posts, error: nil)
            }
        }
        request.type = .Raw
        
        return request
    }
    
    // MARK: Private
    
    class func notesRequest(blog: String, id: Int, beforeTimestamp: Int?, callback: (notes: [Note]?, error: NSError?) -> Void) -> APIRequest<JSONDict> {
        var parameters: [String:AnyObject] = ["id": id]
        if let timestamp = beforeTimestamp {
            parameters["before_timestamp"] = timestamp
        }
        
        let request = APIRequest("notes", blog: blog, parameters: parameters) { (result: JSONDict?, error: NSError?) in
            if let error = collateErrors(result, error) {
                callback(notes: nil, error: error)
            } else if let response = result?["response"] {
                let notes: [Note] = modelize(response["notes"]! as! [JSONDict])
                
                callback(notes: notes, error: nil)
            }
        }
        
        return request
    }
    
    // MARK: - Utilities
    
    class func fullURL(blog: String) -> String {
        if blog.containsString(".") {
            return blog
        }
        
        return "\(blog).tumblr.com"
    }
    
    class func collateErrors(result: JSONDict?, _ error: NSError?) -> NSError? {
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
