//
//  FeedItem.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/8/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation
import UIKit

class FeedItem: NSObject {
    
    var user: FakeUser!
    var imageURL: String!
    var videoURL: URL!
    var image: UIImage!
    var caption: String!
    var createdAt: Date!
    var views: Int = 0
    var likeCount: Int = 0
    var commentCount: Int = 0
    
    init(caption: String, imageURL: String? = nil, image: UIImage? = nil, user: FakeUser) {
        super.init()
        self.caption = caption
        self.imageURL = imageURL
        self.image = image
        self.user = user
        let random = RandomNumber.randomLargeNum()
        self.createdAt = Date().addingTimeInterval(-Double(random))
    }
    
    static func generateFakeData(users: [FakeUser]) -> [FeedItem] {
        let mockService = MockService.make()
        var items = [FeedItem]()
        for index in 0..<users.count {
            let mockImage = getRandomImg(index: index)
            let newFeedItem = FeedItem(caption: mockService.mockCaptions[index], imageURL: mockImage, image: nil, user: users[index])
            items.append(newFeedItem)
        }
        return items
    }
    
    func viewCount() -> String {
        if self.views == 1 {
            return "1 view"
        } else {
            return "\(self.views) views"
        }
    }
    
    func createdAtText() -> String {
        let day = self.createdAt!.dayDiff(toDate: Date())
        switch day {
        case 1:
            return "\(day)d ago"
        case _ where day > 1:
            return "\(day)d ago"
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
    
    static func getRandomImg(index: Int) -> String {
        let images = ["https://i.picsum.photos/id/122/700/1200.jpg?hmac=ZVMrpI-F35pBhB8UQCw4c71dsIe3IhjtFyauXs7QSMw", "https://i.picsum.photos/id/661/700/1200.jpg?hmac=kh2rzkXNqfwCs66C615VDRNIu82TQuUkV0MfeQWk1ms", "https://i.picsum.photos/id/1011/700/1200.jpg?hmac=pB0cJtfmUYEUPMJjr8KuaIacJahH1OZRn7jcHzq4s0Y", "https://i.picsum.photos/id/857/700/1200.jpg?hmac=1THeD-qX8IkuTXk2aTJAvc6GQWqeEK_CZUUIUsbGPIA", "https://i.picsum.photos/id/612/700/1200.jpg?hmac=w1Lf67DYQXr1DQcaL72NXA3RsYbk_hGexQdpZLWxgos"]
        let shuffledImages = images.shuffled()
        if index > images.count - 1 {
            return shuffledImages[0]
        } else {
            return shuffledImages[index]
        }
    }
}

class FakeUser: NSObject {
    
    var username: String!
    var avatarURL: String!
    
    init(username: String, avatarURL: String) {
        super.init()
        self.username = username
        self.avatarURL = avatarURL
    }
}
