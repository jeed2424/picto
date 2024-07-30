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

    public func updateAvatar(user: UUID, avatarName: String, image: Data, completion: @escaping (String?) -> ()) async throws {
        guard let client = SupabaseManager.sharedInstance.client else { return }
        
        let fileName: String = { if avatarName.contains("New_") {
            return user.uuidString
        } else {
            return "New_\(user.uuidString)"
        }}()
        
        let avatarStorageName = { if avatarName.contains("New_") {
            return "New_\(user.uuidString)"
        } else {
            return user.uuidString
        }}()
        
        self.deleteAvatar(avatarName: avatarStorageName, completion: { didDelete in
            if didDelete {
                Task {
                    do {
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
                    } catch {
                        completion(nil)
                    }
                }
                
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
        })
    }
    
    private func deleteAvatar(avatarName: String, completion: @escaping (Bool) -> ()) {
        guard let client = SupabaseManager.sharedInstance.client else { return }
        
        Task {
            do {
                let _ = try await client.storage
                  .from("avatars")
                  .remove(paths: ["public/\(avatarName)"])
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
}
