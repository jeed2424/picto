////
////  PostService.swift
////  InstagramFirestoreTutorial
////
////  Created by Stephen Dowless on 8/31/20.
////  Copyright © 2020 Stephan Dowless. All rights reserved.
////
//
//import UIKit
//import Firebase
//
//struct PostService {
//    
//    static func uploadPost(caption: String, image: UIImage, user: User,
//                           completion: @escaping(FirestoreCompletion)) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        
//        ImageUploader.uploadImage(image: image) { imageUrl in
//            let data = ["caption": caption,
//                        "timestamp": Timestamp(date: Date()),
//                        "likes": 0,
//                        "imageUrl": imageUrl,
//                        "ownerUid": uid,
//                        "ownerImageUrl": user.profileImageUrl,
//                        "ownerUsername": user.username] as [String : Any]
//                        
//            let docRef = COLLECTION_POSTS.addDocument(data: data, completion: completion)
//            
//            if caption.contains("#") {
//                uploadHashtagToServer(forPostId: docRef.documentID, caption: caption)
//            }
//        }
//    }
//    
//    static func updatePost(_ post: Post, newCaption: String, completion: @escaping(FirestoreCompletion)) {
//        if newCaption.contains("#") {
//            uploadHashtagToServer(forPostId: post.postId, caption: newCaption)
//        }
//        
//        COLLECTION_POSTS.document(post.postId).updateData(["caption": newCaption], completion: completion)
//    }
//    
//    static func fetchPosts(completion: @escaping([Post]) -> Void) {
//        COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
//            guard let documents = snapshot?.documents else { return }
//            
//            let posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
//            completion(posts)
//        }
//    }
//    
//    static func fetchPosts(forUser uid: String, completion: @escaping([Post]) -> Void) {
//        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
//        
//        query.getDocuments { (snapshot, error) in
//            guard let documents = snapshot?.documents else { return }
//            
//            var posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
//            posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
//            
//            completion(posts)
//        }
//    }
//    
//    static func fetchPost(withPostId postId: String, completion: @escaping(Post) -> Void) {
//        COLLECTION_POSTS.document(postId).getDocument { snapshot, _ in
//            guard let snapshot = snapshot else { return }
//            guard let data = snapshot.data() else { return }
//            let post = Post(postId: snapshot.documentID, dictionary: data)
//            completion(post)
//        }
//    }
//    
//    static func fetchFeedPosts(completion: @escaping([Post]) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        var posts = [Post]()
//        
//        COLLECTION_USERS.document(uid).collection("user-feed").getDocuments { snapshot, error in
//            snapshot?.documents.forEach({ document in
//                fetchPost(withPostId: document.documentID) { post in
//                    posts.append(post)
//                    posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
//                    
//                    completion(posts)
//                }
//            })
//        }
//    }
//    
//    static func deletePost(_ postId: String, completion: @escaping(FirestoreCompletion)) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        
//        COLLECTION_POSTS.document(postId).collection("post-likes").getDocuments { snapshot, _ in
//            guard let uids = snapshot?.documents.map({ $0.documentID }) else { return }
//            uids.forEach({ COLLECTION_USERS.document($0).collection("user-likes").document(postId).delete() })
//        }
//        
//        COLLECTION_POSTS.document(postId).delete { _ in
//            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
//                guard let uids = snapshot?.documents.map({ $0.documentID }) else { return }
//                
//                uids.forEach({ COLLECTION_USERS.document($0).collection("user-feed").document(postId).delete() })
//                
//                let notificationQuery = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications")
//                notificationQuery.whereField("postId", isEqualTo: postId).getDocuments { snapshot, _ in
//                    guard let documents = snapshot?.documents else { return }
//                    documents.forEach({ $0.reference.delete(completion: completion) })
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Saved Posts
//
//extension PostService {
//    static func savePost(_ postId: String, completion: @escaping(FirestoreCompletion)) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        COLLECTION_USERS.document(uid).collection("saved-posts").document(postId).setData([:], completion: completion)
//    }
//    
//    static func unsavePost(_ postId: String, completion: @escaping(FirestoreCompletion)) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        COLLECTION_USERS.document(uid).collection("saved-posts").document(postId).delete(completion: completion)
//    }
//    
//    static func checkIfUserSavedPost(_ postId: String, completion: @escaping(Bool) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        COLLECTION_USERS.document(uid).collection("saved-posts").document(postId).getDocument { snapshot, _ in
//            guard let exists = snapshot?.exists else { return }
//            completion(exists)
//        }
//    }
//    
//    static func fetchSavedPosts(completion: @escaping([Post]) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        var posts = [Post]()
//        
//        COLLECTION_USERS.document(uid).collection("saved-posts").getDocuments { snapshot, error in
//            snapshot?.documents.forEach({ document in
//                fetchPost(withPostId: document.documentID) { post in
//                    posts.append(post)
//                    posts.sort(by: { $0.timestamp.seconds > $1.timestamp.seconds })
//                    
//                    if posts.count == snapshot?.documents.count {
//                        completion(posts)
//                    }
//                }
//            })
//        }
//    }
//}
//
//// MARK: - Likes
//
//extension PostService {
//    static func likePost(post: Post, completion: @escaping(FirestoreCompletion)) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        
//        COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes + 1])
//        
//        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).setData([:]) { _ in
//            
//            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).setData([:], completion: completion)
//        }
//    }
//    
//    static func unlikePost(post: Post, completion: @escaping(FirestoreCompletion)) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        guard post.likes > 0 else { return }
//        
//        COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes - 1])
//        
//        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).delete { _ in
//            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).delete(completion: completion)
//        }
//    }
//    
//    static func checkIfUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).getDocument { (snapshot, _) in
//            guard let didLike = snapshot?.exists else { return }
//            completion(didLike)
//        }
//    }
//    
//    static func fetchLikedPosts(_ uid: String, completion: @escaping([Post]) -> Void) {
//        var posts = [Post]()
//        
//        COLLECTION_USERS.document(uid).collection("user-likes").getDocuments { snapshot, _ in
//            guard let documents = snapshot?.documents else { return }
//            
//            documents.forEach { doc in
//                let postID = doc.documentID
//                
//                fetchPost(withPostId: postID) { post in
//                    posts.append(post)
//                    
//                    if posts.count == documents.count {
//                        completion(posts)
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Hashtags
//
//extension PostService {
//    private static func uploadHashtagToServer(forPostId postId: String, caption: String) {
//        let words: [String] = caption.components(separatedBy: .whitespacesAndNewlines)
//        
//        for var word in words {
//            if word.hasPrefix("#") {
//                word = word.trimmingCharacters(in: .punctuationCharacters)
//                word = word.trimmingCharacters(in: .symbols)
//                
//                COLLECTION_POSTS.document(postId).updateData([
//                    "hashtags": FieldValue.arrayUnion([word])
//                ])
//            }
//        }
//    }
//    
//    static func fetchPosts(forHashtag hashtag: String, completion: @escaping([Post]) -> Void) {
//        var posts = [Post]()
//        COLLECTION_POSTS.whereField("hashtags", arrayContains: hashtag).getDocuments { (snapshot, error) in
//            guard let documents = snapshot?.documents else { return }
//            
//            documents.forEach({ fetchPost(withPostId: $0.documentID) { post in
//                posts.append(post)
//                completion(posts)
//            } })
//        }
//    }
//}
