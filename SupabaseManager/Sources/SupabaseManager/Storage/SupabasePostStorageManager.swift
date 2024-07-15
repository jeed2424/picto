//
//  File.swift
//  
//
//  Created by Jay Beaudoin on 2024-07-15.
//

import Foundation
import Supabase

class SupabasePostStorageManager {
    
    public static let sharedInstance = SupabasePostStorageManager()

    private init() {}
    
    public func uploadPost(user: UUID, image: Data, completion: @escaping (String?) -> ()) async throws {
        guard let client = SupabaseManager.sharedInstance.client else { return }

        let fileName = image.

        try await client.storage
          .from("posts")
          .upload(
            path: "public/\(fileName)",
            file: image,
            options: FileOptions(
              cacheControl: "3600",
              contentType: "image/png",
              upsert: false
            )
          )
        Task {
            do {
                let publicURL = try client.storage
                  .from("posts")
                  .getPublicURL(path: "public/\(fileName)")
                completion(publicURL.absoluteString)
            } catch {
                completion(nil)
            }
        }
    }
    
    private func retrieveAuthUserPostsNames(user: UUID) async throws -> [String]? {
        guard let client = SupabaseManager.sharedInstance.client else { return nil }
        var postNames: [String]? = []
        var postCount = 0
        
        let posts = try await client.database
            .from("Posts")
            .select()
            .eq("owner", value: user)
            .execute()

        let data = posts.data
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let dataPosts = try decoder.decode([PostObject].self, from: data)
        print(dataPosts)

        if dataPosts.first == nil {
            throw DatabaseError.error
        }
        
        postCount = dataPosts.count
        
        for i in 0...(postCount-1) {
            postNames?.append(dataPosts[i].id)
            
            if i == postCount - 1 {
                return postNames
            } else {
                continue
            }
//            print(dataPosts[i])
        }
//        return dataPosts.first
    }
    
    public func retrievePublicPosts() {
        guard let client = SupabaseManager.sharedInstance.client else { return }
    }
    
    public func retrieveAuthenticatedUserPosts() {
        guard let client = SupabaseManager.sharedInstance.client else { return }
    }
    
    public func retrieveUserPosts() {
        guard let client = SupabaseManager.sharedInstance.client else { return }
    }
}
