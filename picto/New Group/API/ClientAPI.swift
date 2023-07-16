//
//  ClientAPI.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/8/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation
import Alamofire
import Firebase
import FirebaseFirestore
import FirebaseAuth


class ClientAPI {
    static let sharedInstance = ClientAPI()
    let apiVersion = "1.0"
    
    private var requestCache = [URL: CachedResponse]()
    private var preCache = [URL: TimeInterval]()
    
    lazy var mockService: MockService = MockService(api: self)
    lazy var feedService: FeedService = FeedService(api: self)
    lazy var conversationService: ConversationService = ConversationService(api: self)
    lazy var profileService: ProfileService = ProfileService(api: self)
    lazy var postService: BMPostService = BMPostService(api: self)
    lazy var pushService: PushService = PushService(api: self)
    lazy var authenticationService: AuthenticationService = AuthenticationService(api: self)
    
    
    func setUser(user: BMUser) {
        profileService.user = user
    }
    
    
    func requestJson(url: URLConvertible,
                     method: HTTPMethod,
                     parameters: Parameters?,
                     cache_time: TimeInterval = 0,
                     success: (([String:Any]) -> Swift.Void)?,
                     failure: ((String) -> Swift.Void)?) {
        
        let safeUrl = try? url.asURL()
        guard let rawUrl = safeUrl else {
            return
        }
        
        let request = AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.prettyPrinted).responseJSON { response in
            switch (response.result) {
            case .success(let value):
               // let json = response.result.value as! [String:Any]
                success?(value as! [String : Any])
            case .failure:
                // The server crashed trying to process the input
                let networkError = response.error
                failure?(networkError?.localizedDescription ?? "Alamofire network Error")
            }
        }
    }
    
    func requestAPIJson(url: URLConvertible,
                     method: HTTPMethod,
                     parameters: Parameters?,
                     cache_time: TimeInterval = 0,
                     success: (([String:Any]) -> Swift.Void)?,
                     failure: ((String) -> Swift.Void)?) {
        
        let safeUrl = try? url.asURL()
        guard let rawUrl = safeUrl else {
            return
        }
        
//        if cache_time > 0 {
//            // Check if already in cache
//            if let cachedResponse = requestCache[rawUrl] {
//                if CACurrentMediaTime() - cachedResponse.time < cache_time {
//                    DispatchQueue.main.async {
//                        success?(cachedResponse.payload)
//                    }
//                    return
//                }
//            } else {
//                // Check if it's already being loaded in another thread
//                if let preCacheTime = preCache[rawUrl],
//                    CACurrentMediaTime() - preCacheTime < 15 {
//                    print("Already being loaded")
//                    return
//                }
//                preCache[rawUrl] = CACurrentMediaTime()
//            }
//        }
        
        let request = AF.request(url, method:method,
                                        parameters:parameters,
                                        encoding:JSONEncoding.prettyPrinted).responseJSON { response in
                                            switch (response.result) {
                                            case .success(let value):
                                                let json = value as! [String:Any]
                                                let status: String = json["status"] as! String
                                                if (status == "success") {
                                                    print("\(json["response_data"])")
                                                    if status == "success" {
                                                    if let responseData = json["response_data"] as? [String : Any] {
 //                                                        Check Cache
//                                                        if cache_time > 0 {
//                                                            self.requestCache[rawUrl] = CachedResponse(url: url,
//                                                                                                       payload: responseData,
//                                                                                                       time: CACurrentMediaTime())
//                                                        }
                                                        success?(responseData)
                                                    }
                                                    } else {
                                                        failure?("Server returned incorrect data")
//                                                        log.error("Server returned incorrect data", String(describing:json))
                                                    }
                                                } else if (status == "failure") {
                                                    // The transaction was not completed successfully
                                                    let failureString = json["reason"] as? String
                                                    if (failureString != nil) {
                                                        failure?(failureString!)
                                                    } else {
                                                        failure?("No reason for failure given by server")
//                                                        log.error("No reason for failure given by server", String(describing:json))
                                                    }
                                                } else {
//                                                    log.error("Fatal Error. Response has no status")
//                                                    log.error("Fatal Error. Response has no status", String(describing:json))
                                                }
                                            case .failure:
                                                // The server crashed trying to process the input
                                                let networkError = response.error
                                                if (networkError != nil) {
//                                                    log.error("Network Error! The server crashed trying to process the input. Probably not your fault")
//                                                    log.error(url)
//                                                    log.error(response.error?.localizedDescription)
                                                    failure?("\(response.error)")
                                                } else {
//                                                    log.error("Request failed but no error given")
                                                }
                                            }
        }
    }
}

enum ResponseCode {
    case Success
    case Error
}

protocol ServiceDelegate {
    func requestJson(url: URLConvertible, method: HTTPMethod, parameters: Parameters?, success: @escaping (NSDictionary?) -> Swift.Void, failure: @escaping (String?) -> Swift.Void)
}

class CachedResponse {
    let url: URLConvertible
    let payload: [String: Any]
    let time: TimeInterval
    
    init(url: URLConvertible, payload: [String:Any], time: TimeInterval) {
        self.url = url
        self.payload = payload
        self.time = time
    }
}
