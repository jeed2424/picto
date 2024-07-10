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

    public init(id: UUID, username: String, firstName: String, lastName: String, email: String) {
        self.identifier = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = "\(firstName) \(lastName)"
        self.email = email
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

    public init(id: UUID, username: String, firstName: String, lastName: String, email: String) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
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
