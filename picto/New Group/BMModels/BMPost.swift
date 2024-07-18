//
//  BMPost.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/12/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import ObjectMapper

enum PostContentType {
    case photo
    case video
    case all
}

public class BMPost: BMSerializedObject, Comparable {
    override class var identifier: String { return "_BMPost" }
    
    var postID: Int8?
    var user: BMUser?
//    {
//        get {
////            return ObjectLoader.shared.from(id: self.userData!.id!, key: BMUser.identifier) as? BMUser ?? self.userData
//            if let data = self.userData {
//                return ObjectLoader.shared.from(id: data.id!, key: BMUser.identifier) as! BMUser
//            }
//            return nil
//        }
//        set {
//            self.userData = newValue
//        }
////        return ObjectLoader.shared.from(id: self.userData!.id!, key: BMUser.identifier) as? BMUser ?? self.userData
//    }
    var userData: BMUser?
    
    var caption: String?
    var videoUrl: String?
//    var category: String?
    var location: String?
    var likeCount: Int?
    var viewCount: Int? = 0
    var commentCount: Int?
    var createdAt: Date?
    
    var captionExpanded: Bool = false
//    var postI
//    var postImage: UIImage {
//        SDWebImageDownloader.shared.downloadImage(with: URL(string: self.medias.first!.imageUrl!)!, options: [.highPriority]) { (i, d, e, completed) in
//
//        }
//    }
    
//    var image: UIImage {
//        get {
//            return 3.0 * sideLength
//        }
//        set {
//            sideLength = newValue / 3.0
//        }
//    }
    
    var category: BMCategory?
    var medias = [BMPostMedia]()
    var comments = [BMPostComment]()
    
    init(identifier: Int8? = nil, createdAt: Date, user: BMUser, caption: String) {
        super.init()
        self.postID = identifier
        self.userData = user
        self.caption = caption
    }

    // Mappable
    required init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        caption          <- map["caption"]
        videoUrl          <- map["video_url"]
        category      <- (map["category"], BMTransform<BMCategory>())
        location          <- map["location"]
        likeCount          <- map["like_count"]
        viewCount          <- map["views"]
        commentCount          <- map["comment_count"]
        createdAt          <- (map["created_at"], DateTransform())
        userData      <- (map["user"], BMTransform<BMUser>())
        medias      <- (map["medias"], BMListTransform<BMPostMedia>())
        comments      <- (map["comments"], BMListTransform<BMPostComment>())
    }
    
    public static func <(lhs: BMPost, rhs: BMPost) -> Bool {
        return lhs.id < rhs.id
    }
    
    func createdAtText() -> String {
        let x = self.createdAt!.timeIntervalSince1970
        let date = Date(timeIntervalSince1970: x)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let day = date.dayDiff(toDate: Date())
        switch day {
        case 1:
            return "\(day)d ago"
        case _ where day > 1 && day < 365:
            return "\(day)d ago"
        case _ where day > 365:
            return formatter.string(from: date as Date)
        default:
            return self.hourText()
        }
    }
    
    func hourText() -> String {
        let hour = self.createdAt!.hourDiff(toDate: Date())
        switch hour {
        case 1:
            return "\(hour)h ago"
        case _ where hour > 1:
            return "\(hour)h ago"
        default:
            return self.minText()
        }
    }
    
    func minText() -> String {
        let min = self.createdAt!.minDiff(toDate: Date())
        switch min {
        case 1:
            return "\(min)m ago"
        case _ where min > 1:
            return "\(min)m ago"
        default:
            return "Just now"
        }
    }
    
    func contentType() -> PostContentType {
        let media = self.medias.first!
        let hasPhoto = (media.videoUrl == nil)
        let hasVideo = (media.videoUrl != nil)
//        let hasPhoto = self.medias.first(where: {$0.videoUrl == nil})
//        let hasVideo = self.medias.first(where: {$0.videoUrl != nil})
//        if hasVideo != nil && hasPhoto != nil {
//            return .all
//        } else if hasPhoto != nil {
        if hasVideo == true {
            return .video
        } else if hasPhoto == true {
            return .photo
        } else {
            return .video
        }
    }
    
    static public func save(post: inout BMPost) {
        ObjectLoader.shared.cacheObject(post, key: BMPost.identifier)
    }
}

class BMPostMedia: BMSerializedObject, Comparable {
    override class var identifier: String { return "_BMPostMedia" }
    
    var image: UIImage?
    var imageUrl: String?
    var videoUrl: String?
    var gifUrl: String?

    init(imageUrl: String?, videoUrl: String?) {
        super.init()
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
    }

    // Mappable
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        imageUrl          <- map["image_url"]
        videoUrl          <- map["video_url"]
        gifUrl          <- map["gif_url"]
    }
    
    static func <(lhs: BMPostMedia, rhs: BMPostMedia) -> Bool {
        return lhs.id < rhs.id
    }
}

class BMPostLike: BMSerializedObject, Comparable {
    override class var identifier: String { return "_BMPostLike" }
    
    var post: BMPost!
    var comment: BMPostComment!
    var reply: BMPostSubComment!
    var user: BMUser!
    var postId: UInt!
    var commentId: UInt!
    var replyId: UInt!

    init(post: BMPost) {
        super.init()
        self.post = post
        self.postId = post.id!
    }
    
    // Mappable
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        post      <- (map["post"], BMTransform<BMPost>())
        comment      <- (map["comment"], BMTransform<BMPostComment>())
        reply      <- (map["reply"], BMTransform<BMPostSubComment>())
        user      <- (map["user"], BMTransform<BMUser>())
        postId          <- map["id_for_post"]
        commentId          <- map["id_for_comment"]
        replyId          <- map["id_for_reply"]
    }
    
    static func <(lhs: BMPostLike, rhs: BMPostLike) -> Bool {
        return lhs.id < rhs.id
    }
}

class BMPostComment: BMSerializedObject, Comparable {
    override class var identifier: String { return "_BMPostComment" }
    
    var post: BMPost!
    var user: BMUser!
    var message: String!
    var createdAt: Date!
    var replyCount = [Int]()
    var replies = [BMPostSubComment]()
    var showReplies: Bool = false
    var likes: Int!
    var likeCount: Int {
        return likes ?? 0
    }
    
    init(user: BMUser, message: String) {
        super.init()
        self.user = user
        self.message = message
        self.createdAt = Date()
    }

    // Mappable
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        message          <- map["message"]
        likes          <- map["like_count"]
        replyCount          <- map["replies"]
        createdAt          <- (map["created_at"], DateTransform())
        post      <- (map["post"], BMTransform<BMPost>())
        user      <- (map["user"], BMTransform<BMUser>())
    }
    
    static func <(lhs: BMPostComment, rhs: BMPostComment) -> Bool {
        return lhs.id < rhs.id
    }
    
    func createdAtText() -> String {
        let day = self.createdAt!.dayDiff(toDate: Date())
        switch day {
        case 1:
            return "\(day)d"
        case _ where day > 1:
            return "\(day)d"
        default:
            return self.hourText()
        }
    }
    
    func hourText() -> String {
        let hour = self.createdAt!.hourDiff(toDate: Date())
        switch hour {
        case 1:
            return "\(hour)h"
        case _ where hour > 1:
            return "\(hour)h"
        default:
            return self.minText()
        }
    }
    
    func minText() -> String {
        let min = self.createdAt!.minDiff(toDate: Date())
        switch min {
        case 1:
            return "\(min)m"
        case _ where min > 1:
            return "\(min)m"
        default:
            return "Just now"
        }
    }
    
}

class BMPostSubComment: BMSerializedObject, Comparable {
    override class var identifier: String { return "_BMPostSubComment" }
    
    var post: BMPost!
    var comment: BMPostComment!
    var user: BMUser!
    var message: String!
    var createdAt: Date!
    var likes: Int!
    var likeCount: Int {
        return likes ?? 0
    }
    
    init(user: BMUser, message: String) {
        super.init()
        self.user = user
        self.message = message
        self.createdAt = Date()
    }

    // Mappable
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        message          <- map["message"]
        likes          <- map["like_count"]
        createdAt          <- (map["created_at"], DateTransform())
        post      <- (map["post"], BMTransform<BMPost>())
        comment      <- (map["comment"], BMTransform<BMPostComment>())
        user      <- (map["user"], BMTransform<BMUser>())
    }
    
    static func <(lhs: BMPostSubComment, rhs: BMPostSubComment) -> Bool {
        return lhs.id < rhs.id
    }
    
    func createdAtText() -> String {
        let day = self.createdAt!.dayDiff(toDate: Date())
        switch day {
        case 1:
            return "\(day)d"
        case _ where day > 1:
            return "\(day)d"
        default:
            return self.hourText()
        }
    }
    
    func hourText() -> String {
        let hour = self.createdAt!.hourDiff(toDate: Date())
        switch hour {
        case 1:
            return "\(hour)h"
        case _ where hour > 1:
            return "\(hour)h"
        default:
            return self.minText()
        }
    }
    
    func minText() -> String {
        let min = self.createdAt!.minDiff(toDate: Date())
        switch min {
        case 1:
            return "\(min)m"
        case _ where min > 1:
            return "\(min)m"
        default:
            return "Just now"
        }
    }
    
    static public func save(comment: inout BMPostSubComment) {
//        UserSerializer.updateAndSave(object: &user, withJSON: user.toJSON())
        ObjectLoader.shared.cacheObject(comment, key: BMPostSubComment.identifier)
//        if let c = comment.post {
//            ObjectLoader.shared.cacheObject(c, key: BMPost.identifier)
//        }
//        if let r = comment.comment {
//            ObjectLoader.shared.cacheObject(r, key: BMPostComment.identifier)
//        }
    }
}

class BMSavedPost: BMSerializedObject, Comparable {
    override class var identifier: String { return "_BMSavedPost" }
    
    var postId: Int!
    var userId: Int!

    // Mappable
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        postId      <- map["post"]
        userId      <- map["user"]
    }
    
    static func <(lhs: BMSavedPost, rhs: BMSavedPost) -> Bool {
        return lhs.id < rhs.id
    }
}

class BMCategory: BMSerializedObject, Comparable {
    override class var identifier: String { return "_BMCategory" }
    
    var title: String?
    var imageUrl: String?
    
    init(title: String?, imageUrl: String?) {
        self.title = title
        self.imageUrl = imageUrl
        super.init()
    }

    // Mappable
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        title      <- map["title"]
        imageUrl    <- map["image_url"]
    }
    
    static func <(lhs: BMCategory, rhs: BMCategory) -> Bool {
        return lhs.id < rhs.id
    }
}

extension Int {
    
    func countText(text: String) -> String {
        if self == 1 {
            return "\(self) \(text)"
        } else {
            return "\(self) \(text)s"
        }
    }
}

