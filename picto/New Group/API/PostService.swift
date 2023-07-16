//
//  PostService.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/12/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation
import Alamofire
import Firebase
import FirebaseStorage
import AVFoundation
import AVKit
//import FirebaseAnalytics

class BMPostService: BaseService {
    
    override init(api: ClientAPI) {
        super.init(api: api)
    }
    
    static func make() -> BMPostService {
        let post = ClientAPI.sharedInstance.postService
        return post
    }
    
    var selectedCat: BMCategory!
    var videoRef = Storage.storage().reference().child("videos")
    var imageRef = Storage.storage().reference().child("images")
    
    func addComment(post: BMPost, comment: BMPostComment, completion: @escaping (ResponseCode) -> Swift.Void) {
        let params: Parameters = ["post_id": post.id!, "message": comment.message!]
        APIService.requestAPIJson(url:"https://api.warbly.net/post/comment", method: .post, parameters: params, success: { userDict in
            completion(ResponseCode.Success)
        }, failure: { errorString in
            completion(ResponseCode.Error)
        })
    }
    
    func addReply(comment: BMPostComment, reply: BMPostSubComment, sub: BMPostSubComment? = nil, completion: @escaping (ResponseCode) -> Swift.Void) {
        var rep = UInt(0)
        if let r = sub {
            rep = r.id!
        }
        let params: Parameters = ["comment_id": comment.id!, "message": reply.message!, "reply_id": rep]
        APIService.requestAPIJson(url:"https://api.warbly.net/post/comment/reply", method: .post, parameters: params, success: { userDict in
            completion(ResponseCode.Success)
        }, failure: { errorString in
            completion(ResponseCode.Error)
        })
    }
    
    func likePost(post: BMPost, completion: @escaping (ResponseCode, BMUser?) -> Swift.Void) {
//        if me.checkLike(post: post) == true {
//            if let ind = me.postLikes.firstIndex(where: {$0.postId ?? UInt(555555) == post.id!}) {
//                me.postLikes.remove(at: ind)
//            }
//        } else {
//            let l = BMPostLike(post: post)
//            me.postLikes.append(l)
//        }
        completion(ResponseCode.Success, me)
        let params: Parameters = ["post_id": post.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/post/like", method: .post, parameters: params, success: { userDict in
//            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
//            ProfileService.make().user = user
//            completion(ResponseCode.Success, user)
        }, failure: { errorString in
            completion(ResponseCode.Error, nil)
        })
    }
    
    func likeComment(comment: BMPostComment, completion: @escaping (ResponseCode, BMUser?) -> Swift.Void) {
        let params: Parameters = ["comment_id": comment.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/post/comment/like", method: .post, parameters: params, success: { userDict in
            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
    //        ProfileService.make().user = user
            completion(ResponseCode.Success, user)
        }, failure: { errorString in
            completion(ResponseCode.Error, nil)
        })
//        Analytics.logEvent("", parameters: <#T##[String : Any]?#>)
    }
    
    func likeReply(reply: BMPostSubComment, completion: @escaping (ResponseCode, BMUser?) -> Swift.Void) {
        let params: Parameters = ["reply_id": reply.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/post/comment/reply/like", method: .post, parameters: params, success: { userDict in
            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
        //    ProfileService.make().user = user
            completion(ResponseCode.Success, user)
        }, failure: { errorString in
            completion(ResponseCode.Error, nil)
        })
    }
    
    func getReplies(comment: BMPostComment, completion: @escaping (ResponseCode, [BMPostSubComment]) -> Swift.Void) {
        APIService.requestAPIJson(url:"https://api.warbly.net/comment/\(comment.id!)/replies", method: .post, parameters: nil, success: { responseDict in
            let itemDicts = responseDict["replies"] as! [[String:Any]]
            var foundItems = [BMPostSubComment]()
            for itemData in itemDicts {
                foundItems.append(PostSubCommentSerializer.unserialize(JSON: itemData))
            }
            completion(ResponseCode.Success, foundItems)
        }, failure: { errorString in
            completion(ResponseCode.Error, [BMPostSubComment]())
        })
    }
    
    func getLikes(post: BMPost, completion: @escaping (ResponseCode, [BMUser]) -> Swift.Void) {
        let params: Parameters = ["post_id": post.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/post/likes", method: .post, parameters: params, success: { responseDict in
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
    
    func getRelated(post: BMPost? = nil, user: BMUser? = nil, search: String, count: Int, completion: @escaping (ResponseCode, [BMPost]) -> Swift.Void) {
        var params: Parameters = ["search": search, "limit": count]
        var id = 0
        if let p = post {
            id = Int(p.user!.id!)
            params = ["user_id": id, "search": search, "limit": count]
        } else if let u = user {
            id = Int(u.id!)
            params = ["user_id": id, "search": search, "limit": count]
        }
        APIService.requestAPIJson(url:"https://api.warbly.net/post/related", method: .post, parameters: params, success: { responseDict in
            let itemDicts = responseDict["posts"] as! [[String:Any]]
            var foundItems = [BMPost]()
            for itemData in itemDicts {
                foundItems.append(PostSerializer.unserialize(JSON: itemData))
            }
            if let added = post {
                if let index = foundItems.index(of: added) {
                    foundItems.remove(at: index)
                }
            }
            completion(ResponseCode.Success, foundItems)
        }, failure: { errorString in
            completion(ResponseCode.Error, [BMPost]())
        })
    }
    
    func getUserPosts(user: BMUser, completion: @escaping (ResponseCode, [BMPost]) -> Swift.Void) {
        let params: Parameters = ["user_id": user.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/post/me", method: .post, parameters: params, success: { responseDict in
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
    
    func getLikedPosts(user: BMUser, completion: @escaping (ResponseCode, [BMPost]) -> Swift.Void) {
        let params: Parameters = ["user_id": user.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/post/me/liked", method: .post, parameters: params, success: { responseDict in
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
    
    func savePost(post: BMPost, completion: @escaping (ResponseCode, BMUser?) -> Swift.Void) {
        let params: Parameters = ["post_id": post.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/post/save", method: .post, parameters: params, success: { userDict in
            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
      //      ProfileService.make().user = user
            completion(ResponseCode.Success, user)
        }, failure: { errorString in
            completion(ResponseCode.Error, nil)
        })
    }
    
    func deletePost(post: BMPost, completion: @escaping (ResponseCode, BMUser?) -> Swift.Void) {
        let params: Parameters = ["post_id": post.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/post/delete", method: .post, parameters: params, success: { userDict in
            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
     //       ProfileService.make().user = user
            completion(ResponseCode.Success, user)
        }, failure: { errorString in
            completion(ResponseCode.Error, nil)
        })
    }
    
    func viewPost(post: BMPost, completion: @escaping (ResponseCode) -> Swift.Void) {
        let params: Parameters = ["post_id": post.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/post/view", method: .post, parameters: params, success: { _ in
            completion(ResponseCode.Success)
        }, failure: { _ in
            completion(ResponseCode.Error)
        })
    }
    
    func addToCollection(post: BMPost, completion: @escaping (ResponseCode, BMUser?) -> Swift.Void) {
        let params: Parameters = ["post_id": post.id!]
        APIService.requestAPIJson(url:"https://api.warbly.net/user/collection/add/\(post.id!)", method: .post, parameters: params, success: { userDict in
            let user: BMUser = UserSerializer.unserialize(JSON: userDict)
     //       ProfileService.make().user = user
            completion(ResponseCode.Success, user)
        }, failure: { errorString in
            completion(ResponseCode.Error, nil)
        })
    }
    
    func createPost(post: BMPost, image: UIImage?, url: URL?, gifUrl: String, completion: @escaping (ResponseCode, BMPost?) -> Swift.Void) {
        if let vid = url {
            if let img = image {
                self.uploadToFirebaseImage(post: post, image: img, compression: 0.01) { (imgUrl) in
                    self.uploadToFirebaseVideo(url: url!) { (vidUrl) in
                        var params: Parameters = ["caption": post.caption!, "image_url": imgUrl, "video_url": vidUrl, "location": post.location ?? "", "gif_url": gifUrl]
                        if let cat = post.category {
                            params = ["caption": post.caption!, "image_url": imgUrl, "video_url": vidUrl, "category": cat.id!, "location": post.location ?? "", "gif_url": gifUrl]
                        }
                        self.APIService.requestAPIJson(url:"https://api.warbly.net/post/create", method: .post, parameters: params, success: { userDict in
                            let post: BMPost = PostSerializer.unserialize(JSON: userDict)
                            FeedService.make().posts.insert(post, at: 0)
                            completion(ResponseCode.Success, post)
                        }, failure: { errorString in
                            completion(ResponseCode.Error, nil)
                        })
                    } failure: { (error) in
                        completion(ResponseCode.Error, nil)
                    }
                } failure: { (error) in
                    completion(ResponseCode.Error, nil)
                }
            } else {

                self.uploadToFirebaseVideo(url: url!) { (vidUrl) in
                    var params: Parameters = ["caption": post.caption!, "image_url": post.medias.first!.imageUrl ?? "", "video_url": vidUrl, "location": post.location ?? "", "gif_url": gifUrl]
                    if let cat = post.category {
                        params = ["caption": post.caption!, "image_url": post.medias.first!.imageUrl ?? "", "video_url": vidUrl, "category": cat.id!, "location": post.location ?? "", "gif_url": gifUrl]
                    }
                    self.APIService.requestAPIJson(url:"https://api.warbly.net/post/create", method: .post, parameters: params, success: { userDict in
                        let post: BMPost = PostSerializer.unserialize(JSON: userDict)
                        FeedService.make().posts.insert(post, at: 0)
                        completion(ResponseCode.Success, post)
                    }, failure: { errorString in
                        completion(ResponseCode.Error, nil)
                    })
                } failure: { (error) in
                    completion(ResponseCode.Error, nil)
                }
            }
        } else {
            self.uploadToFirebaseImage(post: post, image: image!) { (imgUrl) in
                var params: Parameters = ["caption": post.caption!, "image_url": imgUrl, "video_url": "", "location": post.location ?? ""]
                if let cat = post.category {
                    params = ["caption": post.caption!, "image_url": imgUrl, "video_url": "", "location": post.location ?? "", "category": cat.id!]
                }
                self.APIService.requestAPIJson(url:"https://api.warbly.net/post/create", method: .post, parameters: params, success: { userDict in
                    let post: BMPost = PostSerializer.unserialize(JSON: userDict)
                    FeedService.make().posts.append(post)
                    completion(ResponseCode.Success, post)
                }, failure: { errorString in
                    completion(ResponseCode.Error, nil)
                })
            } failure: { (error) in
                completion(ResponseCode.Error, nil)
            }
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset1280x720) else {
            handler(nil)

            return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
//        exportSession.videoComposition = .
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }

    func uploadToFirebaseVideo(url: URL, success : @escaping (String) -> Void, failure : @escaping (Error) -> Void) {
        
        do {
            let videoData = try  Data.init(contentsOf: url)
//            print(asset.url)
//            self.orginalVideo = asset.url
            print("File size before compression: \(Double(videoData.count / 1048576)) mb")
            let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".MP4")
            print(compressedURL)
            self.compressVideo(inputURL: url, outputURL: compressedURL) { (exportSession) in
                guard let session = exportSession else {
                    return
                }
                switch session.status {
                case .unknown:
                    print("unknown")
                    break
                case .waiting:
                    print("waiting")
                    break
                case .exporting:
                    print("exporting")
                    break
                case .completed:
                    do {
                        let compressedData = try  Data.init(contentsOf: compressedURL)
//                        self.compressVideo = compressedURL
//                        print(compressedData)
                        print("File size AFTER compression: \(Double(compressedData.count / 1048576)) mb")
                        let name = "\(BMUser.me().id!)_\(Int(Date().timeIntervalSince1970)).mp4"
                        self.videoRef = Storage.storage().reference().child("videos").child("\(name)")
                //        Data(contentsOf: URL()
//                        let data = NSData(contentsOf: url)!
//                        print("File size before compression: \(Double(data.length / 1048576)) mb")
                        let meta = StorageMetadata()
                        meta.contentType = "video/mp4"
                        
                        let uploadTask = self.videoRef.putData(compressedData, metadata: meta) { metadata, error in
                            if let error = error {
                                failure(error)
                            }else{
                                if let m = metadata {
                                    let newVid = "https://firebasestorage.googleapis.com/v0/b/warbly-265ed.appspot.com/o/videos%2F\(m.name!)?alt=media"
                                    success(newVid)
                                    
                                } else {
                                    success("error")
                                }
                            }
                            
                        }
                        
                        // Listen for state changes, errors, and completion of the upload.
                        uploadTask.observe(.resume) { snapshot in
                            // Upload resumed, also fires when the upload starts
                        }
                        
                        uploadTask.observe(.pause) { snapshot in
                            // Upload paused
                        }
                        
                        uploadTask.observe(.progress) { snapshot in
                            // Upload reported progress
                        }
                        
                        uploadTask.observe(.success) { snapshot in
                            // Upload completed successfully
                            print("UPLOAD SUCCESFUL")
                        }
                        
                        uploadTask.observe(.failure) { snapshot in
                            if let error = snapshot.error as? NSError {
                                switch (StorageErrorCode(rawValue: error.code)!) {
                                case .objectNotFound:
                                    print("UPLOAD OBJECT NOT FOUND")
                                case .unauthorized:
                                    // User doesn't have permission to access file
                                    //                      break
                                    print("UPLOAD UNAUTHORIZED")
                                case .cancelled:
                                    // User canceled the upload
                                    //                      break
                                    print("UPLOAD CANCELLED")
                                /* ... */
                                
                                case .unknown:
                                    // Unknown error occurred, inspect the server response
                                    //                      break
                                    print("UPLOAD RESPONSE UNKNOWN")
                                default:
                                    // A separate error occurred. This is a good place to retry the upload.
                                    break
                                }
                            }
                        }
                    }
                    catch{
                        print(error)
                    }
                    
                    
                case .failed:
                    print("failed")
                    break
                case .cancelled:
                    print("cancelled")
                    break
                }
            }
        } catch {
            print(error)
            //return
        }
//        let name = "\(BMUser.me().id!)_\(Int(Date().timeIntervalSince1970)).mp4"
//        self.videoRef = Storage.storage().reference().child("videos").child("\(name)")
////        Data(contentsOf: URL()
//        let data = NSData(contentsOf: url)!
//        print("File size before compression: \(Double(data.length / 1048576)) mb")
//        let meta = StorageMetadata()
//        meta.contentType = "video/mp4"
//
//        let uploadTask = self.videoRef.putData(data as Data, metadata: meta) { metadata, error in
//            if let error = error {
//                failure(error)
//            }else{
//                if let m = metadata {
//                    let newVid = "https://firebasestorage.googleapis.com/v0/b/warbly-265ed.appspot.com/o/videos%2F\(m.name!)?alt=media"
//                    success(newVid)
//
//                } else {
//                    success("error")
//                }
//            }
//
//        }
//
//        // Listen for state changes, errors, and completion of the upload.
//        uploadTask.observe(.resume) { snapshot in
//            // Upload resumed, also fires when the upload starts
//        }
//
//        uploadTask.observe(.pause) { snapshot in
//            // Upload paused
//        }
//
//        uploadTask.observe(.progress) { snapshot in
//            // Upload reported progress
//        }
//
//        uploadTask.observe(.success) { snapshot in
//            // Upload completed successfully
//            print("UPLOAD SUCCESFUL")
//        }
//
//        uploadTask.observe(.failure) { snapshot in
//            if let error = snapshot.error as? NSError {
//                switch (StorageErrorCode(rawValue: error.code)!) {
//                case .objectNotFound:
//                    print("UPLOAD OBJECT NOT FOUND")
//                case .unauthorized:
//                    // User doesn't have permission to access file
//                    //                      break
//                    print("UPLOAD UNAUTHORIZED")
//                case .cancelled:
//                    // User canceled the upload
//                    //                      break
//                    print("UPLOAD CANCELLED")
//                /* ... */
//
//                case .unknown:
//                    // Unknown error occurred, inspect the server response
//                    //                      break
//                    print("UPLOAD RESPONSE UNKNOWN")
//                default:
//                    // A separate error occurred. This is a good place to retry the upload.
//                    break
//                }
//            }
//        }
    }
    
    func uploadToFirebaseImage(post: BMPost, image: UIImage, compression: CGFloat = 0.8, success : @escaping (String) -> Void, failure : @escaping (Error) -> Void) {
        
        let name = "\(BMUser.me().id!)_\(Int(Date().timeIntervalSince1970)).jpeg"
        self.imageRef = Storage.storage().reference().child("images").child("\(name)")

        if let uploadData = image.jpegData(compressionQuality: compression) {
            let meta = StorageMetadata()
            meta.contentType = "image/jpeg"
            
            self.imageRef.putData(uploadData, metadata: meta) { metadata, error in
                if let error = error {
                    failure(error)
                }else{
                    if let m = metadata {
                        success("https://firebasestorage.googleapis.com/v0/b/warbly-265ed.appspot.com/o/images%2F\(m.name!)?alt=media")
                    } else {
                        success("metadata path not found")
                    }
                }
                
            }
        }

    }
    
    func uploadToFirebaseGIF(data: Data?, success : @escaping (String) -> Void, failure : @escaping (Error) -> Void) {
        
        let name = "\(BMUser.me().id!)_\(Int(Date().timeIntervalSince1970)).gif"
        self.imageRef = Storage.storage().reference().child("images").child("\(name)")
//        image.da
        if let uploadData = data {
            let meta = StorageMetadata()
            meta.contentType = "image/gif"
            
            self.imageRef.putData(uploadData, metadata: meta) { metadata, error in
                if let error = error {
                    failure(error)
                }else{
                    if let m = metadata {
                        success("https://firebasestorage.googleapis.com/v0/b/warbly-265ed.appspot.com/o/images%2F\(m.name!)?alt=media")
                    } else {
                        success("metadata path not found")
                    }
                }
                
            }
        }

    }
    
}
