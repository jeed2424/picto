////
////  Notification.swift
////  InstagramFirestoreTutorial
////
////  Created by Stephen Dowless on 10/9/20.
////  Copyright © 2020 Stephan Dowless. All rights reserved.
////
//
//import Firebase
//
enum NotificationType: Int {
    case like
    case follow
    case comment

    var notificationMessage: String {
        switch self {
        case .like: return " liked your post."
        case .follow: return " started following you."
        case .comment: return " commented on your post"
        }
    }
}

struct PTNotification {
    let uid: String
    var postImageUrl: String?
    var postId: String?
//    let timestamp: Timestamp
    let type: NotificationType
    let id: String
    let userProfileImageUrl: String
    let username: String
    var userIsFollowed = false

    init(dictionary: [String: Any]) {
//        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.id = dictionary["id"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.postId = dictionary["postId"] as? String ?? ""
        self.postImageUrl = dictionary["postImageUrl"] as? String ?? ""
        self.type = NotificationType(rawValue: dictionary["type"] as? Int ?? 0) ?? .like
        self.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
    }
}
