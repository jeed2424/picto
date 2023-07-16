//
//  BMCollection.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/18/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import ObjectMapper

class BMCollection: BMSerializedObject, Comparable {
    override class var identifier: String { return "_BMCollection" }
    
    var user: BMUser!
    var createdAt: Date!
    var posts = [BMCollectionPost]()

    init(user: BMUser) {
        super.init()
        self.user = user
        self.createdAt = Date()
    }

    // Mappable
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        createdAt          <- (map["created_at"], DateTransform())
        posts      <- (map["posts"], BMListTransform<BMCollectionPost>())
        user      <- (map["user"], BMTransform<BMUser>())
    }
    
    static func <(lhs: BMCollection, rhs: BMCollection) -> Bool {
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
}

class BMCollectionPost: BMSerializedObject, Comparable {
    override class var identifier: String { return "_BMCollectionPost" }
    
    var user: BMUser!
    var post: BMPost!
    var createdAt: Date!
    
    init(post: BMPost) {
        super.init()
        self.post = post
        self.createdAt = Date()
    }

    // Mappable
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        createdAt          <- (map["created_at"], DateTransform())
        post      <- (map["post"], BMTransform<BMPost>())
        user      <- (map["user"], BMTransform<BMUser>())
    }
    
    static func <(lhs: BMCollectionPost, rhs: BMCollectionPost) -> Bool {
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
}
