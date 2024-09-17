//
//  Networking.swift
//  picto
//
//  Created by Jay on 2024-09-08.
//

import Foundation
import Alamofire
import SupabaseManager

class Networking {
    public static let sharedInstance = Networking()

    let baseUrl = baseUrlConstant().stringValue
    let apiKey = supabaseApiKeyConstant().stringValue

    func fetchPosts(completion: @escaping ([BMPost]?) -> Void) {

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]

        let supabaseUrl = "\(baseUrl)fetch-items"
        // Make GET request to Supabase function
        AF.request(supabaseUrl, method: .get, headers: headers)
            .validate()  // Checks for HTTP errors (status code 200-299)
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    print("Data received: \(data)")
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase  // Converts snake_case to camelCase

                        // Attempt to decode the data into an array of PostObject
                        if let data = response.data {
                            let dataPost = try decoder.decode([PostObject].self, from: data)
                            print("Decoded posts: \(dataPost)")

                            // Ensure there's at least one post
                            if dataPost.first == nil {
                                throw DatabaseError.error
                            }

                            // Return or process the decoded posts
                            print("Successfully decoded: \(dataPost)")

                            let posts: [BMPost] = dataPost.compactMap({ post in
                                self.createBMPostIfUserMissing(post: post)
                            })

                            completion(posts)

                        } else {
                            completion(nil)
                        }

                    } catch {
                        print("Decoding error: \(error)")
                        completion(nil)
                    }

                case .failure(let error):
                    print("Error: \(error)")
                    completion(nil)
                }
            }
    }

    private func createBMPostIfUserMissing(post: PostObject) -> BMPost {
        if let userID = post.owner {
            let bmPost = BMPost(identifier: post.identifier, createdAt: post.createdAt?.dateAndTimeFromString(), user: {
                if let dbUser = post.owner {
                    let user: BMUser = BMUser(id: dbUser.identifier, username: dbUser.username, firstName: dbUser.firstName, lastName: dbUser.lastName, email: dbUser.email, bio: dbUser.bio, website: dbUser.website, showFullName: dbUser.showFullName, avatar: dbUser.avatar, posts: [])
                    return user
                } else {
                    return nil
                }
            }(), caption: post.caption, location: "", category: nil, commentCount: post.commentCount, likeCount: Int8(post.likes?.count ?? 0), comments: nil,medias: {
                post.images?.compactMap({ image in BMPostMedia(imageUrl: image, videoUrl: nil) })
            }()
            )

//            getUserForPost(user: userID, completion: { user in
//                if let user = user {
//                    bmPost.user = user
//                }
//            })

            return bmPost
        } else {
            return BMPost(identifier: post.identifier, createdAt: post.createdAt?.dateAndTimeFromString(), user: nil, caption: post.caption, location: "", category: nil, commentCount: post.commentCount, likeCount: Int8(post.likes?.count ?? 0), comments: nil,medias: {
                post.images?.compactMap({ image in BMPostMedia(imageUrl: image, videoUrl: nil) })
            }()
            )
        }
    }

    private func getUserForPost(user: UUID, completion: @escaping (BMUser?) -> ()) {
        Task {
            do {
                if let dbUser = try await SupabaseAuthenticationManager.sharedInstance.getUserForPost(user: user) {
                    let bmUser = BMUser(id: dbUser.id, username: dbUser.username, firstName: dbUser.firstName, lastName: dbUser.lastName, email: dbUser.email, bio: dbUser.bio, website: dbUser.website, showFullName: dbUser.showFullName, avatar: dbUser.avatar, posts: [])
                    completion(bmUser)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
    }
}

//private func awaitFetchUserPosts(user: UUID) async throws -> [PostObject]? {
//    guard let client = SupabaseManager.sharedInstance.client else { return nil }
//
//    let newPost = try await client.database
//        .from("Posts")
//        .select()
//        .eq("owner", value: user.uuidString.lowercased())
//        .execute()
//
//    let data = newPost.data
//    let decoder = JSONDecoder()
//    decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//    let dataPost = try decoder.decode([PostObject].self, from: data)
//    print(dataPost)
//
//    if dataPost.first == nil {
//        throw DatabaseError.error
//    }
//    return dataPost
//}
