//
//  File.swift
//  
//
//  Created by Jay on 2024-07-16.
//

import Foundation

public class SupabaseDatabaseManager {

    public static let sharedInstance = SupabaseDatabaseManager()

    private init() {

    }

    private func awaitUploadPost(user: DbUser, post: DbPost) async throws -> PostObject? {
        guard let client = SupabaseManager.sharedInstance.client else { return nil }

        try await client.database
            .from("Posts")
            .insert(post)
    //                    .select()
        // specify you want a single value returned, otherwise it returns a list.
            .execute()

        let newPost = try await client.database
            .from("Posts")
            .select()
    //                    .match(["user_id": user.user_id.uuidString.lowercased()])
            .eq("owner", value: user.identifier.uuidString.lowercased())
            .eq("image", value: post.image)
            .limit(1)
            .execute()

        let data = newPost.data
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let dataPost = try decoder.decode([PostObject].self, from: data)
        print(dataPost)

        if dataPost.first == nil {
            throw DatabaseError.error
        }
        return dataPost.first
    }

    public func uploadPost(user: DbUser, post: DbPost, completion: @escaping (PostObject?) -> ()) {
    //        guard let client = SupabaseManager.sharedInstance.client else { return }
        Task {
            do {
                let newPost = try await awaitUploadPost(user: user, post: post)
//                self.authenticatedUser = NewBMUser(id: newUser?.identifier ?? UUID(), username: newUser?.username ?? "", firstName: newUser?.firstName ?? "", lastName: newUser?.lastName ?? "", email: newUser?.email ?? "", bio: "", website: "", showFullName: false, avatar: "", posts: [])
                completion(newPost)
            } catch {
                print("Wrongggg")
                completion(nil)
            }
        }
    }

    public func fetchUserPosts(user: DbUser, completion: @escaping ([PostObject]?) -> ()) {
        Task {
            do {
                let userPosts = try await self.awaitFetchUserPosts(user: user)
                completion(userPosts)
            } catch {
                print("Wrongggg")
                completion(nil)
            }
        }
    }

    private func awaitFetchUserPosts(user: DbUser) async throws -> [PostObject]? {
        guard let client = SupabaseManager.sharedInstance.client else { return nil }

        let newPost = try await client.database
            .from("Posts")
            .select()
            .eq("owner", value: user.identifier.uuidString.lowercased())
            .execute()

        let data = newPost.data
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let dataPost = try decoder.decode([PostObject].self, from: data)
        print(dataPost)

        if dataPost.first == nil {
            throw DatabaseError.error
        }
        return dataPost
    }
}
