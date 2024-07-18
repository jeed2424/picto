//
//  ProfileService.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/12/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation
import Alamofire
import Firebase
import SupabaseManager
//import FirebaseFirestore

class ProfileService: BaseService {

    public static let sharedInstance = ProfileService(api: ClientAPI.sharedInstance)

    override init(api: ClientAPI) {
        super.init(api: api)
    }

//    let db = Firestore.firestore()
    var following = [BMUser]()
    var categories = [BMCategory]()
    var user: BMUser? {
        didSet {
            print("Hello on user set: \(user?.avatar)")
        }
    }
    var tabController: UITabBarController? //CustomTabBarController!
    var videoRef = Storage.storage().reference().child("videos")
    var imageRef = Storage.storage().reference().child("images")
    
    static func make() -> ProfileService {
        let profile = ClientAPI.sharedInstance.profileService
        return profile
    }

    func saveUser(user: BMUser) {
        self.user = user
    }

    func updateUser(user: BMUser) {
        self.user = user
    }

    func updateAvatar(user: BMUser, completion: @escaping (ResponseCode, BMUser?) -> Swift.Void) {
        let params: Parameters = ["avatar": user.avatar!]
        APIService.requestAPIJson(url:"https://api.warbly.net/user/update/avatar", method: .post, parameters: params, success: { userDict in
            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
            self.user = user
            completion(ResponseCode.Success, user)
        }, failure: { errorString in
            completion(ResponseCode.Error, nil)
        })
    }
    
    func checkUsername(username: String, completion: @escaping (ResponseCode) -> Swift.Void) {
        let params: Parameters = ["username": username]
        APIService.requestAPIJson(url:"https://api.warbly.net/user/check_username", method: .post, parameters: params, success: { userDict in
            completion(ResponseCode.Success)
        }, failure: { errorString in
            completion(ResponseCode.Error)
        })
    }
    
    func updateProfile(user: BMUser, completion: @escaping (ResponseCode, BMUser?) -> Swift.Void) {
        let params: Parameters = ["id": user.id!, "username": user.username ?? nil, "instagram": user.instagram ?? nil, "bio": user.bio ?? nil, "website": user.website ?? nil, "avatar": user.avatar!]
        APIService.requestAPIJson(url:"https://us-central1-picto-ce462.cloudfunctions.net/updateProfile", method: .post, parameters: params, success: { userDict in
            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
            self.user = user
            completion(ResponseCode.Success, user)
        }, failure: { errorString in
            completion(ResponseCode.Error, nil)
        })
    }
    
    func updateUser(user: BMUser, completion: @escaping (ResponseCode, BMUser?) -> Swift.Void) {
        let params: Parameters = ["id": user.id!, "username": user.username!.noSpaces()]
        APIService.requestAPIJson(url:"https://us-central1-picto-ce462.cloudfunctions.net/updateUsername", method: .post, parameters: params, success: { userDict in
            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
            self.user = user
            completion(ResponseCode.Success, user)
        }, failure: { errorString in
            completion(ResponseCode.Error, nil)
        })
    }
    
    func followUser(user: BMUser, completion: @escaping (ResponseCode, BMUser?) -> Swift.Void) {
        let params: Parameters = ["user_id": user.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/user/follow", method: .post, parameters: params, success: { userDict in
            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
            self.user = user
            completion(ResponseCode.Success, user)
        }, failure: { errorString in
            completion(ResponseCode.Error, nil)
        })
    }
    
    func getFollowers(user: BMUser, completion: @escaping (ResponseCode, [BMUser]) -> Swift.Void) {
        let params: Parameters = ["user_id": user.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/user/followers", method: .post, parameters: params, success: { responseDict in
            let itemDicts = responseDict["users"] as! [[String:Any]]
            var foundItems = [BMUser]()
            for itemData in itemDicts {
                foundItems.append(UserSerializer.unserialize(JSON: itemData))
            }
            completion(ResponseCode.Success, foundItems)
        }, failure: { errorString in
            completion(ResponseCode.Error, [BMUser]())
        })
    }
    
    func getFollowing(user: BMUser, discover: Bool = false, completion: @escaping (ResponseCode, [BMUser]) -> Swift.Void) {
        let params: Parameters = ["user_id": user.id!, "discover": discover]
        APIService.requestAPIJson(url:"https://api.warbly.net/user/following", method: .post, parameters: params, success: { responseDict in
            let itemDicts = responseDict["users"] as! [[String:Any]]
            var foundItems = [BMUser]()
            for itemData in itemDicts {
                foundItems.append(UserSerializer.unserialize(JSON: itemData))
            }
            completion(ResponseCode.Success, foundItems)
        }, failure: { errorString in
            completion(ResponseCode.Error, [BMUser]())
        })
    }
    
    func searchUsers(search: String, completion: @escaping (ResponseCode, [BMUser]) -> Swift.Void) {
        let params: Parameters = ["search": search]
        APIService.requestAPIJson(url:"https://api.warbly.net/search/users", method: .post, parameters: params, success: { responseDict in
            let itemDicts = responseDict["users"] as! [[String:Any]]
            var foundItems = [BMUser]()
            for itemData in itemDicts {
                foundItems.append(UserSerializer.unserialize(JSON: itemData))
            }
            completion(ResponseCode.Success, foundItems)
        }, failure: { errorString in
            completion(ResponseCode.Error, [BMUser]())
        })
    }
    
    func getCategories(user: BMUser, completion: @escaping (ResponseCode, [BMCategory]) -> Swift.Void) {
        let manager = SupabaseDatabaseManager.sharedInstance
        manager.getCategories(completion: { categories in
            if let cats: [BMCategory] = categories?.compactMap({ category in BMCategory(title: category.title, imageUrl: category.imageUrl) }) {
                completion(ResponseCode.Success, cats)
            } else {
                completion(ResponseCode.Error, [])
            }
        })
    }
    
    func loadUser(user: BMUser, completion: @escaping (ResponseCode, BMUser?) -> Swift.Void) {
//        let params: Parameters = ["user_id": user.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/user/load/\(user.id!)", method: .post, parameters: nil, success: { userDict in
            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
//            self.user = user
            completion(ResponseCode.Success, user)
        }, failure: { errorString in
            completion(ResponseCode.Error, nil)
        })
    }
    
    func loadConversations(user: BMUser, completion: @escaping (ResponseCode, [BMConversation]) -> Swift.Void) {
//        let params: Parameters = ["user_id": user.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/user/conversations/load/\(user.id!)", method: .post, parameters: nil, success: { responseDict in
            let itemDicts = responseDict["conversations"] as! [[String:Any]]
            var foundItems = [BMConversation]()
            for itemData in itemDicts {
                foundItems.append(ConversationSerializer.unserialize(JSON: itemData))
            }
        }, failure: { errorString in
            completion(ResponseCode.Error, [BMConversation]())
        })
    }
    
    func toggleName(user: BMUser, completion: @escaping (ResponseCode, BMUser?) -> Swift.Void) {
//        me.showName = !me.showName!
//        APIService.requestAPIJson(url:"https://api.warbly.net/user/show_name", method: .post, parameters: nil, success: { userDict in
//            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
            completion(ResponseCode.Success, user)
//        }, failure: { errorString in
//            completion(ResponseCode.Error, nil)
//        })
    }
    
    func uploadToFirebaseImage(user: BMUser, image: UIImage, success : @escaping (String) -> Void, failure : @escaping (Error) -> Void) {
        
//        let name = "\(BMUser.me().id)_\(Int(Date().timeIntervalSince1970)).jpeg"
//        self.imageRef = Storage.storage().reference().child("images").child("\(name)")
//
//        if let uploadData = image.jpegData(compressionQuality: 0.5) {
//            let meta = StorageMetadata()
//            meta.contentType = "image/jpeg"
//            
//            self.imageRef.putData(uploadData, metadata: meta) { metadata, error in
//                if let error = error {
//                    failure(error)
//                }else{
//                    if let m = metadata {
//                        success("https://firebasestorage.googleapis.com/v0/b/warbly-265ed.appspot.com/o/images%2F\(m.name!)?alt=media")
//                    } else {
//                        success("metadata path not found")
//                    }
//                }
//                
//            }
//        }

    }

}
