//
//  PostObject.swift
//
//
//  Created by Jay Beaudoin on 2024-07-15.
//

import Foundation

public struct PostObject: Decodable {
    public let identifier: Int8
    public let created_at: String
    public let owner: UUID
    public let caption: String
    public let images: [String]
    public let likeCount: Int8
    public let commentCount: Int8
    public let comments: [String]
}

public struct CommentObject: Decodable {
    public let id: Int
    public let created_at: String
    public let owner: UUID
    public let comment: String
}

public struct DbPost: Encodable {
    public let identifier: Int8?
    public let created_at: String?
    public let owner: UUID?
    public let caption: String?
    public let images: [String]?
    public let likeCount: Int8?
    public let commentCount: Int8?
    public let comments: [String]?

    public init(identifier: Int8?, createdAt: String, owner: UUID, caption: String, images: [String], likeCount: Int8, commentCount: Int8, comments: [String]) {
        self.identifier = identifier
        self.created_at = createdAt
        self.owner = owner
        self.caption = caption
        self.images = images
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.comments = comments
//        {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            let dateString = dateFormatter.string(from: Date.now)
//            return dateString
//        }()
    }
}
