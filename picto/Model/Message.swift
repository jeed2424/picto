//
//  Message.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 10/12/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import Firebase

struct Message {
    let text: String
    let toId: String
    let fromId: String
    var timestamp: Date?
    let profileImageUrl: String
    let isFromCurrentUser: Bool
    let username: String
    
    var chatPartnerId: String { return isFromCurrentUser ? toId : fromId }
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.toId = dictionary["toId"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.isFromCurrentUser = fromId == Auth.auth().currentUser?.uid
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
    }
}
