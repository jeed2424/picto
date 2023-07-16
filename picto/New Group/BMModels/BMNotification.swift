//
//  BMNotification.swift
//  Warbly
//
//  Created by Knox Dobbins on 3/23/21.
//  Copyright © 2021 Warbly. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import ObjectMapper

class BMNotification: BMSerializedObject, Comparable {
    override class var identifier: String { return "_BMNotification" }
    
    var user: BMUser!
    var createdAt: Date!
    var post: BMPost!
    var title: String!
    var body: String!
    var type: Int!
    
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
        title          <- map["title"]
        body          <- map["body"]
        createdAt          <- (map["created_at"], DateTransform())
        post      <- (map["post"], BMTransform<BMPost>())
        user      <- (map["user"], BMTransform<BMUser>())
    }
    
    static func <(lhs: BMNotification, rhs: BMNotification) -> Bool {
        return lhs.id > rhs.id
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
            return "\(hour)h"
        case _ where hour > 1:
            return "\(hour)h"
        default:
            return self.minText()
        }
    }
    
    func minText() -> String {
        let min = self.createdAt!.minDiff(toDate: Date())
        switch min {
        case 1:
            return "\(min)m"
        case _ where min > 1:
            return "\(min)m"
        default:
            return "Just now"
        }
    }
}
