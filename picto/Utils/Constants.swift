//
//  Constants.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 6/27/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import Firebase

let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
let COLLECTION_POSTS = Firestore.firestore().collection("posts")
let COLLECTION_NOTIFICATIONS = Firestore.firestore().collection("notifications")
let COLLECTION_MESSAGES = Firestore.firestore().collection("messages")

let DEFAULT_PROFILE_IMAGE_URL = "https://firebasestorage.googleapis.com/v0/b/instagramfirestoretutorial.appspot.com/o/profile_images%2Fdefault-profile-image.jpg?alt=media&token=530b496a-5a07-466e-8797-876a0035f393"
