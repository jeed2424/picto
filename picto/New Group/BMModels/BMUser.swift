import UIKit
import SDWebImage
import Alamofire
import ObjectMapper
import FirebaseAuth

public class BMUser: BMSerializedObject, Comparable {
    override class var identifier: String { return "_BMUser" }
    
    var identifier: UUID?
    var username: String!
    var firstName: String!
    var lastName: String!
    var fullName: String {
        return "\(self.firstName!) \(self.lastName!)"
    }
    var email: String!
    var bio: String!
    var website: String!
    var fcmToken: String!
    var notiCount: Int!
    var avatar: String!
    var coverPhoto: String!
    var createdAt: Date!
    var showName: Bool!
    
    //socials
    var twitter: String!
    var instagram: String!
    var tiktok: String!
    var youtube: String!
    var pinterest: String!
    var snapchat: String!

    var socials: [String] {
        var links = [String]()
        links.append(self.twitter ?? "none")
        links.append(self.instagram ?? "none")
        links.append(self.tiktok ?? "none")
        links.append(self.youtube ?? "none")
        links.append(self.snapchat ?? "none")
        links.append(self.pinterest ?? "none")
        return links.filter({$0 != "none"})
    }
    
    var following = [UUID]()
    var followers = [UUID]()
    
    var collection: BMCollection!
    var posts = [BMPost]()
    var notifications = [BMNotification]()
    var conversations = [BMConversation]()
    var savedPosts = [BMSavedPost]()
    var postLikes = [BMPostLike]()
    
    static public func me() -> BMUser? {
        return ProfileService.sharedInstance.user
    }
    
    init(avatar: String) {
        super.init()
        self.avatar = avatar
    }

    init(id: UUID, username: String, firstName: String, lastName: String, email: String) {
        self.identifier = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email

        super.init()
    }

    // Mappable
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
        username          <- map["username"]
        firstName          <- map["firstName"]
        lastName          <- map["lastName"]
        avatar          <- map["avatar"]
        coverPhoto          <- map["cover_photo"]
        bio          <- map["bio"]
        showName          <- map["show_name"]
        instagram          <- map["instagram"]
        website          <- map["website"]
        email          <- map["email"]
        fcmToken          <- map["fcm_token"]
        following          <- map["following"]
        followers          <- map["followers"]
        createdAt          <- (map["created_at"], DateTransform())
        posts      <- (map["posts"], BMListTransform<BMPost>())
        notifications      <- (map["notifications"], BMListTransform<BMNotification>())
        postLikes      <- (map["post_likes"], BMListTransform<BMPostLike>())
        savedPosts      <- (map["saved_posts"], BMListTransform<BMSavedPost>())
        conversations      <- (map["conversations"], BMListTransform<BMConversation>())
        collection      <- (map["collection"], BMTransform<BMCollection>(required: true))
    }
    
    static public func <(lhs: BMUser, rhs: BMUser) -> Bool {
        return lhs.id < rhs.id
    }
    
    func checkFollow(user: BMUser) -> Bool {
        if let follows = self.following.first(where: {$0 == user.identifier}) {
            return true
        } else if let otherFollows = user.followers.first(where: {$0 == self.identifier}) {
            return true
        } else {
            return false
        }
    }
    
    func checkSaved(post: BMPost) -> Bool {
        if let saved = self.savedPosts.first(where: {$0.postId! == Int(post.id!)}) {
            return true
        } else {
            return false
        }
    }
    
    func checkCollection(post: BMPost) -> Bool {
        if let saved = self.collection?.posts.first(where: {$0.post!.id! == post.id!}) {
            return true
        } else {
            return false
        }
    }
    
    func checkLike(post: BMPost) -> Bool {
        //        let likes = self.postLikes.filter({
        //            if let p = $0.postId {
        //                if p == post.id! {
        //                    return true
        //                }
        //            }
        //            return false
        //        })
        //        if let ind
        //        return likes.count > 0
        if let ind = self.postLikes.firstIndex(where: {$0.postId ?? UInt(555555) == post.id!}) {
            return true
        } else {
            return false
        }
    }
    
    func checkLike(comment: BMPostComment) -> Bool {
        //        let likes = self.postLikes.filter({
        //            if let comm = $0.commentId {
        //                if comm == comment.id! {
        //                    return true
        //                }
        //            }
        //            return false
        //        })
        //        return likes.count > 0
        if let ind = self.postLikes.firstIndex(where: {$0.commentId ?? UInt(555555) == comment.id!}) {
            return true
        } else {
            return false
        }
    }
    
    func checkLike(reply: BMPostSubComment) -> Bool {
        //        let likes = self.postLikes.filter({
        //            if let rep = $0.replyId {
        //                if rep == reply.id! {
        //                    return true
        //                }
        //            }
        //            return false
        //        })
        //        return likes.count > 0
        if let ind = self.postLikes.firstIndex(where: {$0.replyId ?? UInt(555555) == reply.id!}) {
            return true
        } else {
            return false
        }
    }
    
    func followUser(user: BMUser) {
        if let uid = self.identifier, let index = self.following.firstIndex(of: uid) {
            self.following.remove(at: index)
            if let ind = user.followers.firstIndex(of: uid) {
                user.followers.remove(at: ind)
            }
        } else {
            if let uuid = user.identifier {
                self.following.append(uuid)
                user.followers.append(uuid)
            }
        }
        
    }
    
    func unreadMessages() -> Int {
        var count = Int(0)
        let m = self.conversations.map({$0.lastMessage != nil && $0.lastMessage!.unread! == true && $0.lastMessage!.senderId! != self.id!})
        for i in m {
            if i == true {
                count += 1
                print("has unread! \(count)")
            }
        }
        return count
        //        if m.contains(true) {
        //            return 1
        //        } else {
        //            return 0
        //        }
        
    }
    
    static public func save(user: inout BMUser) {
        //        UserSerializer.updateAndSave(object: &user, withJSON: user.toJSON())
        ObjectLoader.shared.cacheObject(user, key: BMUser.identifier)
        if let c = user.collection {
            ObjectLoader.shared.cacheObject(c, key: BMCollection.identifier)
        }
        //        print("SAVING NEW USER CACHE: ", user.toJSON())
        //        UserSerializer.unserialize(JSON: self.toJSON())
        //        ObjectLoader.shared.cacheObject(self, key: BMSerializer<BMUser>.from(id: self.id!).id!)
        
        //        let objects = ObjectLoader.shared.getCachedObjects(self)
        
        //        for i in objects {
        //            ObjectLoader.shared.cacheObject(i, key: BMUser.identifier)
        //            UserSerializer.updateAndSave(object: &user, withJSON: user.toJSON())
        //            if let ob = i as? BMUser {
        ////                ObjectLoader.shared.cacheObject(i.id!, key: UserS)
        ////                let new = UserSerializer.unserialize(JSON: ob.toJSON())
        //                print("SAVING NEW USER CACHE: ", ob.toJSON())
        //            }
        //        }

        //        if let index = ObjectLoader.shared.cache.values.first({$0 == [self.id!: self] as! [UInt: BMSerializedObjectType]}) {
        //
        //        }
        //        BMSerializer<BMUser>.from(id: self.id!) = self
    }

}
