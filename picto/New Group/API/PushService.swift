//
//  PushService.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/12/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation
import Alamofire
import UserNotifications

class PushService: BaseService {
    
    let disposer = BMDisposer()
    var pushToken: String?
    
    override init(api: ClientAPI) {
        super.init(api: api)
    }
    
    static func make() -> PushService {
        let push = ClientAPI.sharedInstance.pushService
        return push
    }
    
    func updateFCMToken(token: String, completion: ((ResponseCode) -> Swift.Void)?) {

        let parameters: Parameters = ["user_id": BMUser.me().id!, "token": token]
        APIService.requestAPIJson(url:URL(string: "https://api.warbly.net/user/update/fcm")!, method: .post, parameters: parameters, success: { responseDict in
            completion?(ResponseCode.Success)
        }, failure: { errorString in
            log.error(errorString)
            completion?(ResponseCode.Error)
        })
    }
    
}
