//
//  File.swift
//  
//
//  Created by Jay Beaudoin on 2024-07-15.
//

import Foundation
import Supabase

public class SupabasePostStorageManager {
    
    public static let sharedInstance = SupabasePostStorageManager()

    private init() {}

    public func uploadPost(user: UUID?, image: Data?, completion: @escaping (String?) -> ()) {
        Task {
            do {
                try await awaitUploadPost(user: user, image: image, completion: { postURL in
                    completion(postURL)
                })
            } catch {
                completion(nil)
            }
        }
    }

    private func awaitUploadPost(user: UUID?, image: Data?, completion: @escaping (String?) -> ()) async throws {
        guard let client = SupabaseManager.sharedInstance.client, let user = user, let image = image else { throw DatabaseError.error }

        let fileName = try await getNewPostName(user: user)

        try await client.storage
          .from("posts")
          .upload(
            path: "public/\(fileName)",
            file: image,
            options: FileOptions(
              cacheControl: "3600",
              contentType: "image/jpeg",
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
    
    private func getNewPostName(user: UUID) async throws -> String {
        guard let client = SupabaseManager.sharedInstance.client else { return "1_\(user.uuidString)" }

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
            return "1_\(user.uuidString)"
        } else {
            return "\(dataPosts.count + 1)_\(user.uuidString)"
        }
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
