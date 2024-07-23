//
//  PostObject.swift
//
//
//  Created by Jay Beaudoin on 2024-07-15.
//

import Foundation

public struct PostObject: Decodable {
    public let identifier: Int8?
    public let createdAt: String?
    public let owner: UUID?
    public let caption: String?
    public let images: [String]?
    public let likeCount: Int8?
    public let commentCount: Int8?
    public let comments: [String]?
}

public struct CommentObject: Decodable {
    public let id: Int
    public let createdAt: String
    public let owner: UUID
    public let comment: String
}

public struct DbPost: Encodable {
    public let identifier: Int8?
    public let createdAt: String?
    public let owner: UUID?
    public let caption: String?
    public let images: [String]?
    public let likeCount: Int8?
    public let commentCount: Int8?
    public let comments: [String]?

    public init(identifier: Int8?, createdAt: String?, owner: UUID?, caption: String?, images: [String]?, likeCount: Int8?, commentCount: Int8?, comments: [String]?) {
        self.identifier = identifier
        self.createdAt = createdAt
        self.owner = owner
        self.caption = caption
        self.images = images
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.comments = comments
        
//        func json(from object:Any) -> String? {
//            guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
//                return nil
//            }
//            return String(data: data, encoding: String.Encoding.utf8)
//        }
//
//        print("\(json(from:array as Any))")
//        {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            let dateString = dateFormatter.string(from: Date.now)
//            return dateString
//        }()
    }
}
