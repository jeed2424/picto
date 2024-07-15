//
//  PostObject.swift
//
//
//  Created by Jay Beaudoin on 2024-07-15.
//

import Foundation

public struct PostObject: Decodable {
    let id: String
    let created_at: Date
    let owner: UUID
    let image: String
    let comments: [String]
}

public struct CommentObject: Decodable {
    let id: Int
    let created_at: Date
    let owner: UUID
    let comment: String
}
