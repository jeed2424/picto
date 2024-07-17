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
    public let image: String
    public let comments: [String]
    public let likeCount: Int8
}

public struct CommentObject: Decodable {
    public let id: Int
    public let created_at: String
    public let owner: UUID
    public let comment: String
}

public struct DbPost: Encodable {
    public let identifier: Int8?
    public let created_at: String
    public let owner: UUID
    public let image: String
    public let comments: [String]
    public let likeCount: Int8

    public init(identifier: Int8?, createdAt: String, owner: UUID, image: String, comments: [String], likeCount: Int8) {
        self.identifier = identifier
        self.created_at = createdAt
//        {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            let dateString = dateFormatter.string(from: Date.now)
//            return dateString
//        }()
        self.owner = owner
        self.image = image
        self.comments = comments
        self.likeCount = likeCount
    }
}
