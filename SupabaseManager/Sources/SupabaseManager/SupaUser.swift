//
//  File.swift
//  
//
//  Created by Jay on 2024-03-28.
//

import Foundation

public struct SupaUser {
    public let id: UUID
    public let email: String

    public init(id: UUID, email: String) {
        self.id = id
        self.email = email
    }
}

public struct DbUser: Encodable {
    public let identifier: UUID
    public let username: String
    public let firstName: String
    public let lastName: String
    public let fullName: String
    public let email: String
    public let bio: String
    public let website: String
    public let showFullName: Bool
    public let avatar: String
    public let posts: [Int8]

    public init(id: UUID, username: String, firstName: String, lastName: String, email: String, bio: String, website: String, showFullName: Bool, avatar: String, posts: [Int8]) {
        self.identifier = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = "\(firstName) \(lastName)"
        self.email = email
        self.bio = bio
        self.website = website
        self.showFullName = showFullName
        self.avatar = avatar
        self.posts = posts
    }
}

public struct SupabaseDbUser: Codable {
    let id: UUID
    let username: String
    let firstName: String
    let lastName: String
    var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }
    let email: String
}

public struct NewBMUser {
    public let id: UUID
    public let username: String
    public let firstName: String
    public let lastName: String
    public var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }
    public let email: String
    public var bio: String
    public var website: String
    public var showFullName: Bool
    public var avatar: String
    public var posts: [Int8]

    public init(id: UUID, username: String, firstName: String, lastName: String, email: String, bio: String, website: String, showFullName: Bool, avatar: String, posts: [Int8]) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.bio = bio
        self.website = website
        self.showFullName = showFullName
        self.avatar = avatar
        self.posts = posts
    }
}

//let country: Country = try await supabase.database
//  .from("countries")
//  .insert(Country(id: 1, name: "Denmark"))
//  .select()
//  // specify you want a single value returned, otherwise it returns a list.
//  .single()
//  .execute()
//  .value
