//
//  Post.swift
//  Treadr
//
//  Created by Joshua Basch on 9/19/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

enum PostFormat: String {
    case HTML = "html"
    case Markdown = "markdown"
}

enum PostType: String {
    case Text = "text"
    case Photo = "photo"
    case Quote = "quote"
    case Link = "link"
    case Chat = "chat"
    case Audio = "audio"
    case Video = "video"
    case Answer = "answer"
}

enum PostState: String {
    case Published = "published"
    case Queued = "queued"
    case Draft = "draft"
    case Private = "private"
}

func == (left: Post, right: Post) -> Bool {
    return left.id == right.id
}

class Post: NSObject, ModelType {
    
    var content: String = ""
    
    var blogName: String
    var canReply: Bool = true
    var date: Date
    var followed: Bool
    var format: PostFormat
    var id: Int
    var liked: Bool
    var linkURL: String?
    var noteCount: Int
    var postURL: String
    var reblogKey: String
    var shortURL: String
    var slug: String
    var sourceTitle: String?
    var sourceURL: String?
    var state: PostState
    var tags: [String] = []
    var timestamp: Int
    var trail: [Trail] = []
    var type: PostType
    
    // reblog_info
    var rebloggedFromFollowing: Bool?
    var rebloggedFromID: Int?
    var rebloggedFromName: String?
    var rebloggedFromTitle: String?
    var rebloggedFromURL: String?
    var rebloggedRootFollowing: Bool?
    var rebloggedRootID: Int?
    var rebloggedRootName: String?
    var rebloggedRootTitle: String?
    var rebloggedRootURL: String?
    
    // notes_info
    var notes: [Note]?
    
    // Shared
    var title: String?   // Text, Link, Chat
    var photos: [Photo]? // Photo, Link
    var body: String?    // Text, Chat
    var caption: String? // Photo, Audio, Video
    
    // Photo
    var imagePermalink: String? = nil
    var photosetLayout: [Int] = [1]
    
    // Quote
    var text: String?
    var source: String?
    
    // Link
    var URL: String?
    var linkAuthor: String?
    var linkImage: String?
    var excerpt: String?
    var publisher: String?
    
    // Chat
    var dialogue: [[String:String]]?
    
    // Audio
    var embed: String?
    var player: String?
    var plays: Int?
    var albumArt: String?
    var artist: String?
    var album: String?
    var audioType: String?
    var audioURL: String?
    var trackName: String?
    var trackNumber: Int?
    var year: Int?
    
    // Video
    var duration: Int?
    var HTML5Capable: Bool?
    var permalinkURL: String?
    var players: [[String:AnyObject]]?
    var thumbnailHeight: Int?
    var thumbnailURL: String?
    var thumbnailWidth: Int?
    var videoType: String?
    var videoURL: String?
    
    // Answer
    var askingName: String?
    var askingURL: String?
    var question: String?
    var answer: String?
    
    required init(dict: JSONDict) {
        blogName = dict["blog_name"]! as! String
        canReply = dict["can_reply"]! as! Bool
        date = Post.dateFormatter.date(from: dict["date"]! as! String)!
        followed = dict["followed"]! as! Bool
        format = PostFormat(rawValue: dict["format"]! as! String)!
        id = dict["id"]! as! Int
        liked = dict["liked"]! as! Bool
        linkURL = dict["link_url"] as! String?
        noteCount = dict["note_count"]! as! Int
        postURL = dict["post_url"]! as! String
        reblogKey = dict["reblog_key"]! as! String
        shortURL = dict["short_url"]! as! String
        sourceTitle = dict["source_title"] as? String
        sourceURL = dict["source_url"] as? String
        slug = dict["slug"]! as! String
        state = PostState(rawValue: dict["state"]! as! String)!
        tags = dict["tags"]! as! [String]
        timestamp = dict["timestamp"]! as! Int
        if let rawTrail = dict["trail"] {
            trail = modelize(rawTrail as! [[String:AnyObject]])
        }
        type = PostType(rawValue: dict["type"]! as! String)!
        
        rebloggedFromFollowing = dict["reblogged_from_following"] as? Bool
        rebloggedFromID = dict["reblogged_from_id"] as? Int
        rebloggedFromName = dict["reblogged_from_name"] as? String
        rebloggedFromTitle = dict["reblogged_from_title"] as? String
        rebloggedFromURL = dict["reblogged_from_url"] as? String
        rebloggedRootFollowing = dict["reblogged_root_following"] as? Bool
        rebloggedRootID = dict["reblogged_root_id"] as? Int
        rebloggedRootName = dict["reblogged_root_name"] as? String
        rebloggedRootTitle = dict["reblogged_root_title"] as? String
        rebloggedRootURL = dict["reblogged_root_url"] as? String
        
        if let rawNotes = dict["notes"] {
            notes = modelize(rawNotes as! [[String:AnyObject]])
        }
        
        // Shared
        title = dict["title"] as? String
        if title == "<null>" {
            title = nil
        }
        if let rawPhotos = dict["photos"] {
            photos = modelize(rawPhotos as! [[String:AnyObject]])
        }
        body = dict["body"] as? String
        caption = dict["caption"] as? String
        
        switch type {
        case .Text:
            content = Post.buildContent(tags, parts: [title, body])
        case .Photo:
            imagePermalink = dict["image_permalink"] as? String
            if let layout = dict["photoset_layout"] as! String? {
                photosetLayout = layout.characters.map() { (char: Character) -> Int in
                    return Int("\(char)")!
                }
            }
            
            content = Post.buildContent(tags, parts: [caption])
        case .Quote:
            text = (dict["text"] as? String)?.replacingOccurrences(of: "<[^>]*>", with: "", options: [.regularExpression], range: nil)
            source = dict["source"] as? String
            
            content = Post.buildContent(tags, parts: [text, source])
        case .Link:
            URL = dict["url"] as? String
            linkAuthor = dict["link_author"] as? String
            linkImage = dict["link_image"] as? String
            excerpt = dict["excerpt"] as? String
            publisher = dict["publisher"] as? String
            
            content = Post.buildContent(tags, parts: [linkAuthor, excerpt, publisher, dict["description"] as? String])
        case .Chat:
            dialogue = dict["dialogue"] as? [[String:String]]
            
            content = Post.buildContent(tags, parts: [title, body])
        case .Audio:
            embed = dict["embed"] as? String
            player = dict["player"] as? String
            plays = dict["plays"] as? Int
            albumArt = dict["album_art"] as? String
            artist = dict["artist"] as? String
            album = dict["album"] as? String
            audioType = dict["audio_type"] as? String
            audioURL = dict["audio_url"] as? String
            
            if let tn = dict["track_name"] as? String {
                trackName = tn
            } else {
                trackName = "Listen"
            }
            
            trackNumber = dict["track_number"] as? Int
            year = dict["year"] as? Int
            
            content = Post.buildContent(tags, parts: [artist, album, trackName, caption])
        case .Video:
            duration = dict["duration"] as? Int
            HTML5Capable = dict["html5_capable"] as! Bool?
            permalinkURL = dict["permalink_url"] as? String
            players = dict["player"] as? [[String:AnyObject]]
            thumbnailHeight = dict["thumbnail_height"] as? Int
            thumbnailURL = dict["thumbnail_url"] as? String
            thumbnailWidth = dict["thumbnail_width"] as? Int
            videoType = dict["video_type"] as? String
            videoURL = dict["video_url"] as? String
            
            content = Post.buildContent(tags, parts: [caption])
        case .Answer:
            askingName = dict["asking_name"] as? String
            askingURL = dict["asking_url"] as? String
            question = (dict["question"] as? String)?.replacingOccurrences(of: "<[^>]*>", with: "", options: [.regularExpression], range: nil)
            answer = dict["answer"] as? String
            
            content = Post.buildContent(tags, parts: [askingName, question, answer])
        }
    }

    override var description: String {
        let reblog = rebloggedFromName != nil ? " ↻ \(rebloggedFromName!)" : ""
        return "\(type.rawValue): \(blogName)\(reblog)"
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/dd HH:mm:ss zzz"
        return formatter
    }()
    
    private class func buildContent(_ tags: [String], parts: [String?]) -> String {
        var c = ""
        
        for part in parts {
            if let p = part {
                c += "\(p) "
            }
        }
        
        c = c.replacingOccurrences(of: "<[^>]*>", with: "", options: [.regularExpression], range: nil)
        c = c + tags.joined(separator: " ")
        c = c.lowercased()
        
        return c
    }
    
}
