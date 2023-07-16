//
//  FeedService.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/12/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation
import Alamofire
import Firebase

class FeedService: BaseService {
    
    override init(api: ClientAPI) {
        super.init(api: api)
    }
    
    var user: User!
    var posts = [BMPost]()
    
    static func make() -> FeedService {
        let feed = ClientAPI.sharedInstance.feedService
        return feed
    }
    
    func getFeed(all: Bool, completion: @escaping (ResponseCode, [BMPost]) -> Swift.Void) {
        APIService.requestAPIJson(url: URL(string: "https://us-central1-picto-ce462.cloudfunctions.net/getfeed")!,
                               method: .post,
                               parameters: nil,
                               cache_time: 0,
                               success: { responseDict in
                                let itemDicts = responseDict["posts"] as! [[String:Any]]
                                var foundItems = [BMPost]()
                                for itemData in itemDicts {
                                    foundItems.append(PostSerializer.unserialize(JSON: itemData))
                                }
                                completion(ResponseCode.Success, foundItems)
                               }, failure: { errorString in
                                completion(ResponseCode.Error, [BMPost]())
                               })
    }
    
    func getFollowingFeed(all: Bool, completion: @escaping (ResponseCode, [BMPost]) -> Swift.Void) {
        APIService.requestAPIJson(url: URL(string: "https://api.warbly.net/feed/following")!,
                               method: .post,
                               parameters: nil,
                               cache_time: 0,
                               success: { responseDict in
                                let itemDicts = responseDict["posts"] as! [[String:Any]]
                                var foundItems = [BMPost]()
                                for itemData in itemDicts {
                                    foundItems.append(PostSerializer.unserialize(JSON: itemData))
                                }
                                completion(ResponseCode.Success, foundItems)
                               }, failure: { errorString in
                                completion(ResponseCode.Error, [BMPost]())
                               })
    }

}
