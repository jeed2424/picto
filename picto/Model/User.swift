//
//  User.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 6/27/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let email: String
    var fullname: String
    var profileImageUrl: String
    var username: String
    let uid: String
    let fcmToken: String
    var bio: String?
    var website: String?
    
    var isFollowed = false
    
    var stats: UserStats!
    
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid }
    
    init(dictionary: [String: Any]) {
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.fcmToken = dictionary["fcmToken"] as? String ?? ""
        
        if let bio = dictionary["bio"] as? String {
            self.bio = bio
        }
        
        if let website = dictionary["website"] as? String {
            self.website = website
        }
        
        self.stats = UserStats(followers: 0, following: 0, likes: 0)
    }

    init(email: String, fullname: String, profileImageUrl: String, username: String, uid: String, fcmToken: String, bio: String, website: String) {
        self.email = email
        self.fullname = fullname
        self.profileImageUrl = profileImageUrl
        self.username = username
        self.uid = uid
        self.fcmToken = fcmToken

        self.bio = bio

        self.website = website

        self.stats = UserStats(followers: 0, following: 0, likes: 0)
    }
}

struct UserStats {
    let followers: Int
    let following: Int
    let likes: Int
}
