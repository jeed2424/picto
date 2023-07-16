//
//  BMConversation.swift
//  Gala
//
//  Created by Knox Dobbins on 4/20/21.
//  Copyright © 2021 Warbly. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import ObjectMapper

class BMConversation: BMSerializedObject, Comparable {
    override class var identifier: String { return "_BMConversation" }
    
    var sender: BMUser!
    var receiver: BMUser!
    var createdAt: Date!
    var lastUpdate: Date!
    var lastMessage: BMMessage!
    var messages = [BMMessage]()

    init(sender: BMUser, receiver: BMUser) {
        super.init()
        self.sender = sender
        self.receiver = receiver
        self.lastUpdate = Date()
        self.createdAt = Date()
    }

    // Mappable
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        createdAt          <- (map["created_at"], DateTransform())
        lastUpdate          <- (map["created_at"], DateTransform())
        messages      <- (map["messages"], BMListTransform<BMMessage>())
        lastMessage      <- (map["last_message"], BMTransform<BMMessage>())
        sender      <- (map["sender"], BMTransform<BMUser>())
        receiver      <- (map["receiver"], BMTransform<BMUser>())
    }
    
    static func <(lhs: BMConversation, rhs: BMConversation) -> Bool {
        return lhs.id < rhs.id
    }
    
    func createdAtText() -> String {
        let day = self.lastUpdate!.dayDiff(toDate: Date())
        switch day {
        case 1:
            return "\(day)d"
        case _ where day > 1:
            return "\(day)d"
        default:
            return self.hourText()
        }
    }
    
    func hourText() -> String {
        let hour = self.lastUpdate!.hourDiff(toDate: Date())
        switch hour {
        case 1:
            return "\(hour)h"
        case _ where hour > 1:
            return "\(hour)h"
        default:
            return self.minText()
        }
    }
    
    func minText() -> String {
        let min = self.lastUpdate!.minDiff(toDate: Date())
        switch min {
        case 1:
            return "\(min)m"
        case _ where min > 1:
            return "\(min)m"
        default:
            return "Just now"
        }
    }
    
    static public func save(convo: inout BMConversation) {
        ObjectLoader.shared.cacheObject(convo, key: BMConversation.identifier)
    }
}

class BMMessage: BMSerializedObject, Comparable {
    override class var identifier: String { return "_BMMessage" }
    
    var senderId: UInt!
//    var sender: BMUser!
    var body: String!
    var convoId: UInt!
    var createdAt: Date!
    var lastUpdate: Date!
    var unread: Bool!

    init(body: String, convoId: UInt) {
        super.init()
        self.body = body
        self.senderId = me.id!
        self.convoId = convoId
        self.unread = true
        self.createdAt = Date()
        self.lastUpdate = Date()
    }

    // Mappable
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        createdAt          <- (map["created_at"], DateTransform())
        lastUpdate          <- (map["last_update"], DateTransform())
        unread      <- map["unread"]
        body      <- map["body"]
        senderId      <- map["sender_id"]
        convoId      <- map["conversation_id"]
    }
    
    static func <(lhs: BMMessage, rhs: BMMessage) -> Bool {
        return lhs.id < rhs.id
    }
    
    func createdAtText() -> String {
        let day = self.createdAt!.dayDiff(toDate: Date())
        switch day {
        case 1:
            return "\(day)d"
        case _ where day > 1:
            return "\(day)d"
        default:
            return self.hourText()
        }
    }
    
    func hourText() -> String {
        let hour = self.createdAt!.hourDiff(toDate: Date())
        switch hour {
        case 1:
            return "\(hour)h ago"
        case _ where hour > 1:
            return "\(hour)h ago"
        default:
            return self.minText()
        }
    }
    
    func minText() -> String {
        let min = self.createdAt!.minDiff(toDate: Date())
        switch min {
        case 1:
            return "\(min)m ago"
        case _ where min > 1:
            return "\(min)m ago"
        default:
            return "Just now"
        }
    }
    
    static public func save(message: inout BMMessage) {
        ObjectLoader.shared.cacheObject(message, key: BMMessage.identifier)
    }
}
