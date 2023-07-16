//
//  AuthService.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 6/25/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

typealias DatabaseCompletion = ((Error?) -> Void)

struct AuthService {
    static func logUserIn(withEmail email: String, password: String, completion: @escaping(AuthDataResult?, (any Error)?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(withCredential credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        
        ImageUploader.uploadImage(image: credentials.profileImage) { imageUrl in
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
                if let error = error {
                    print("DEBUG: Failed to register user \(error.localizedDescription)")
                    return
                }
                
                guard let uid = result?.user.uid else { return }
                
                var data: [String: Any] = ["email": credentials.email,
                                           "fullname": credentials.fullname,
                                           "profileImageUrl": imageUrl,
                                           "uid": uid,
                                           "username": credentials.username]
                
                if let fcmToken = Messaging.messaging().fcmToken {
                    data["fcmToken"] = fcmToken
                }
                
                COLLECTION_USERS.document(uid).setData(data, completion: completion)
            }
        }
    }
    
    static func resetPassword(withEmail email: String, completion: @escaping(Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
    static func loginWithFacebook(_ credential: AuthCredential, completion: @escaping(String?, Bool, Error?) -> Void) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                completion(nil, false, error)
                return
            }
            
            guard let user = result?.user else { return }
            
            let data: [String: Any] = ["email": user.email ?? "",
                                       "profileImageUrl": DEFAULT_PROFILE_IMAGE_URL,
                                       "fullname": user.displayName ?? "",
                                       "uid": user.uid]
            
            COLLECTION_USERS.document(user.uid).getDocument { snapshot, _ in
                guard let snapshot = snapshot else { return }
                
                if snapshot.exists {
                    COLLECTION_USERS.document(user.uid).updateData(data) { _ in
                        completion(nil, false, nil)
                    }
                } else {
                    COLLECTION_USERS.document(user.uid).setData(data) { _ in
                        completion(user.uid, true, nil)
                    }
                }
            }
        }
    }
    
    static func validateUsername(_ username: String, completion: @escaping(Bool) -> Void) {
        COLLECTION_USERS.whereField("username", isEqualTo: username).getDocuments { snapshot, _ in
            guard let isValid = snapshot?.isEmpty else { return }
            completion(isValid)
        }
    }
    
    static func uploadUsername(_ username: String, toUid uid: String, completion: @escaping(FirestoreCompletion)) {
        COLLECTION_USERS.document(uid).updateData(["username": username], completion: completion)
    }
}

extension AuthService {
    static func loginWithGoogle(didSignInFor user: GIDGoogleUser, completion: @escaping(String?, Bool, Error?) -> Void) {

        let credential = GoogleAuthProvider.credential(withIDToken: user.idToken?.tokenString ?? "", accessToken: user.accessToken.tokenString)
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                completion(nil, false, error)
                return
            }
            
            guard let resultUser = result?.user else { return }
            
            let data: [String: Any] = ["email": resultUser.email ?? "",
                                       "fullname": resultUser.displayName ?? "",
                                       "profileImageUrl": DEFAULT_PROFILE_IMAGE_URL,
                                       "uid": resultUser.uid]
            
            COLLECTION_USERS.document(resultUser.uid).getDocument { snapshot, _ in
                guard let snapshot = snapshot else { return }
                
                if snapshot.exists {
                    COLLECTION_USERS.document(resultUser.uid).updateData(data) { _ in
                        completion(nil, false, nil)
                    }
                } else {
                    COLLECTION_USERS.document(resultUser.uid).setData(data) { _ in
                        completion(resultUser.uid, true, nil)
                    }
                }
            }
        }
    }
}
