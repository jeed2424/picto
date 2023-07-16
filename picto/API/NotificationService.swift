//
//  NotificationService.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 10/9/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import Firebase

struct NotificationService {
    
    static func uploadNotification(toUid uid: String, fromUser: User,
                                   type: NotificationType, post: Post? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return }
        
        let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
        
        var data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                   "uid": fromUser.uid,
                                   "type": type.rawValue,
                                   "id": docRef.documentID,
                                   "userProfileImageUrl": fromUser.profileImageUrl,
                                   "username": fromUser.username]
        
        if let post = post {
            data["postId"] = post.postId
            data["postImageUrl"] = post.imageUrl
        }
        
        docRef.setData(data)
    }
    
    static func deleteNotification(toUid uid: String, type: NotificationType, postId: String? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications")
            .whereField("uid", isEqualTo: currentUid).getDocuments { snapshot, _ in
                snapshot?.documents.forEach({ document in
                    let notification = PTNotification(dictionary: document.data())
                    guard notification.type == type else { return }
                    
                    if postId != nil {
                        guard postId == notification.postId else { return }
                    }
                    
                    document.reference.delete()
                })
            }
    }
    
    static func fetchNotifications(completion: @escaping([PTNotification]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query =  COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications")
            .order(by: "timestamp", descending: true)
       
            query.getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let notifications = documents.map({ PTNotification(dictionary: $0.data()) })
            completion(notifications)
        }
    }
}
