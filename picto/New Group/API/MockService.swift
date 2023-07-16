//
//  MockService.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/8/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation
import Alamofire
import Firebase

class MockService: BaseService {
    
    override init(api: ClientAPI) {
        super.init(api: api)
    }
    var user: User!
    var fakeUsers = [FakeUser]()
    var mockCaptions = [String]()
    var mockFeedItems = [FeedItem]()
    
    static func make() -> MockService {
        let mock = ClientAPI.sharedInstance.mockService
        return mock
    }
    
    func getMockUsers(count: Int, completion: ((ResponseCode, [FakeUser]) -> Swift.Void)?) {
        APIService.requestJson(url: URL(string: "https://randomuser.me/api/?results=\(count)&inc=name,picture")!,
                               method: .get,
                               parameters: nil,
                               success: { json in
                                
                                guard let results = json["results"] as? [[String:Any]] else {
                                    completion?(ResponseCode.Error, [FakeUser]())
                                    return
                                }
                                
                                var randomData = [FakeUser]()
                                for item in results {
                                    let newUser = FakeUser(username: "", avatarURL: "")
                                    if let nameJson = item["name"] as? [String:Any] {
                                        let firstName = nameJson["first"] as! String
                                        let lastName = nameJson["last"] as! String
                                        newUser.username = "\(firstName)\(lastName)".lowercased()
                                    }
                                    if let avatarJson = item["picture"] as? [String:Any] {
                                        let avatar = avatarJson["large"] as! String
                                        print("user avatar: ", avatar)
                                        newUser.avatarURL = avatar
                                        // Add random generated user to array
                                        randomData.append(newUser)
                                    }
                                }
                                
                                completion?(ResponseCode.Success, randomData)
                                
        }, failure: { errorString in
            completion?(ResponseCode.Error, [FakeUser]())
        })
    }
    
    func getMockCaptions(count: Int, completion: ((ResponseCode, [String]) -> Swift.Void)?) {
        APIService.requestJson(url: URL(string: "https://api.quotable.io/quotes?limit=\(count)&minLength=30&maxLength=100")!,
                               method: .get,
                               parameters: nil,
                               success: { json in
                                
                                guard let response = json as? [String:Any] else {
                                    completion?(ResponseCode.Error, [String]())
                                    return
                                }
                                
                                guard let results = response["results"] as? [[String:Any]] else {
                                    print("Could not parse caption results")
                                    completion?(ResponseCode.Error, [String]())
                                    return
                                }
                                
                                var randomCaptions = [String]()
                                for item in results {
                                    if let caption = item["content"] as? String {
                                        randomCaptions.append(caption)
                                    }
                                }
                                
                                completion?(ResponseCode.Success, randomCaptions)
                                
        }, failure: { errorString in
            completion?(ResponseCode.Error, [String]())
        })
    }
    
    func createNewFeedItem(image: UIImage? = nil, videoUrl: URL? = nil, completion: ((ResponseCode) -> Swift.Void)?) {
//        let newFakeUser = FakeUser(username: self.user!.username, avatarURL: self.user!.profileImageUrl)
//        self.fakeUsers.append(newFakeUser)
//        self.getMockCaptions(count: 1) { (response, newCaption) in
//            if response == .Success {
//                self.mockCaptions.append(contentsOf: newCaption)
//                let newItem = FeedItem(caption: newCaption.first ?? "", imageURL: nil, image: image ?? nil, user: newFakeUser)
//                newItem.videoURL = videoUrl ?? nil
//                self.mockFeedItems.insert(newItem, at: 0)
//                completion?(ResponseCode.Success)
//            } else {
//                print("Error generating fake captions")
//                completion?(ResponseCode.Error)
//            }
//        }
    }
    
    func addNewFeedItem(item: FeedItem) {
        self.fakeUsers.append(item.user!)
        self.mockFeedItems.insert(item, at: 0)
    }
}
    
