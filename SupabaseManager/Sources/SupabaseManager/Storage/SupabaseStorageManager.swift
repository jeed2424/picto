//
//  SupabaseStorageManager.swift
//  
//
//  Created by Jay on 2024-07-13.
//

import Foundation
import Supabase

public class SupabaseStorageManager {
    public static let sharedInstance = SupabaseStorageManager()

    private init() {
        
    }

    public func uploadAvatar(user: UUID, image: Data, completion: @escaping (String?) -> ()) async throws {
        guard let client = SupabaseManager.sharedInstance.client else { return }

        let fileName = user.uuidString

        try await client.storage
          .from("avatars")
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
                  .from("avatars")
                  .getPublicURL(path: "public/\(fileName)")
                completion(publicURL.absoluteString)
            } catch {
                completion(nil)
            }
        }
    }

    public func updateAvatar(user: UUID, image: Data, completion: @escaping (String?) -> ()) async throws {
        guard let client = SupabaseManager.sharedInstance.client else { return }

        let fileName = user.uuidString

        try await client.storage
          .from("avatars")
          .upload(
            path: "public/\(fileName)",
            file: image,
            options: FileOptions(
              cacheControl: "3600",
              contentType: "image/jpeg",
              upsert: false
            )
          )

        Task
        {
            do {
                Task {
                    do {
                        let publicURL = try client.storage
                          .from("avatars")
                          .getPublicURL(path: "public/\(fileName)")
                        completion(publicURL.absoluteString)
                    } catch {
                        completion(nil)
                    }
                }
            } catch {
                completion(nil)
            }
        }
    }
}
