//
//  ConversationService.swift
//  Gala
//
//  Created by Knox Dobbins on 4/20/21.
//  Copyright © 2021 Warbly. All rights reserved.
//

import Foundation
import Alamofire
import Firebase
import FirebaseStorage
import AVFoundation
import AVKit
//import FirebaseAnalytics

class ConversationService: BaseService {
    
    override init(api: ClientAPI) {
        super.init(api: api)
    }
    
    static func make() -> ConversationService {
        let convo = ClientAPI.sharedInstance.conversationService
        return convo
    }

    func newConvo(receiver: BMUser, completion: @escaping (ResponseCode, BMConversation?) -> Swift.Void) {
        let params: Parameters = ["receiver_id": receiver.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/conversation/create", method: .post, parameters: params, success: { userDict in
            let convo: BMConversation = ConversationSerializer.unserialize(JSON: userDict)
            completion(ResponseCode.Success, convo)
        }, failure: { errorString in
            completion(ResponseCode.Error, nil)
        })
    }
    
    func newMessage(message: String, conversation: BMConversation, completion: @escaping (ResponseCode) -> Swift.Void) {
        let params: Parameters = ["conversation_id": conversation.id!, "message": message]
        APIService.requestAPIJson(url:"https://api.warbly.net/conversation/message", method: .post, parameters: params, success: { userDict in
            completion(ResponseCode.Success)
        }, failure: { errorString in
            completion(ResponseCode.Error)
        })
    }
    
    func loadMessages(conversation: BMConversation, completion: @escaping (ResponseCode, [BMMessage]) -> Swift.Void) {
//        let params: Parameters = ["user_id": user.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/conversation/messages/load/\(conversation.id!)", method: .post, parameters: nil, success: { responseDict in
            let itemDicts = responseDict["messages"] as! [[String:Any]]
            var foundItems = [BMMessage]()
            for itemData in itemDicts {
                foundItems.append(MessageSerializer.unserialize(JSON: itemData))
            }
        }, failure: { errorString in
            completion(ResponseCode.Error, [BMMessage]())
        })
    }

}
