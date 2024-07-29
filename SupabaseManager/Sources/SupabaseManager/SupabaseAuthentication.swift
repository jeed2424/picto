//
//  SupabaseAuthentication.swift
//
//
//  Created by Jay on 2023-09-30.
//
import Foundation
import Supabase

public struct databaseUsers: Decodable {
    let users: [databaseUser]
}

public struct databaseUser: Decodable {
    let identifier: UUID
//    let created_at: String
    let username: String
    let firstName: String
    let lastName: String
    let fullName: String
    let email: String
    let bio: String
    let website: String
    let showFullName: Bool
    let avatar: String
    let posts: [Int8]
}

public enum AuthResponse {
    case success
    case error
}

public enum DatabaseError: Error {
    case error
}

public enum AuthService {
    case github
    case email
}

public enum AuthOptions {
    case signup
    case signin
}

public class SupabaseAuthenticationManager {

    public static let sharedInstance = SupabaseAuthenticationManager()

    public var authenticatedUser: NewBMUser? {
        didSet {
            if let user = authenticatedUser {
                print("Hello authenticatedUser \(user.username)")
            }
        }
    }

    private var user: User?

    private init () {
    }
    
    public func currentUser(completion: @escaping (NewBMUser?) -> ()) {
        self.getActiveUser(completion:  { user in
            self.user = user
            
            if let user = user {
                Task {
                    do {
                        if let activeUser = try await self.getActiveUserData(user: user) {
                            if try await self.userIsAdmin(user: activeUser) ?? false {
                                let newBmUser = NewBMUser(id: activeUser.identifier, username: activeUser.username, firstName: activeUser.firstName, lastName: activeUser.lastName, email: activeUser.email, bio: activeUser.bio, website: activeUser.website, showFullName: activeUser.showFullName, avatar: activeUser.avatar, posts: activeUser.posts, isAdmin: true)
                                completion(newBmUser)
                            } else {
                                let newBmUser = NewBMUser(id: activeUser.identifier, username: activeUser.username, firstName: activeUser.firstName, lastName: activeUser.lastName, email: activeUser.email, bio: activeUser.bio, website: activeUser.website, showFullName: activeUser.showFullName, avatar: activeUser.avatar, posts: activeUser.posts, isAdmin: false)
                                completion(newBmUser)
                            }
                        }
                    } catch {
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        })
    }
    
    private func getActiveUser(completion: @escaping (User?) -> ()) {
        SupabaseManager.sharedInstance.getActiveUser(completion: { user in
            if let user = user {
                completion(user)
            } else {
                completion(nil)
            }
        })
    }
    
    public func userIsAdmin(user: databaseUser) async throws -> Bool? {
        
        struct dbAdmin: Decodable {
            let identifier: UUID
        }
        
        guard let client = SupabaseManager.sharedInstance.client else { return nil }

        let newUser = try await client.database
            .from("Admins")
            .select()
            .eq("userid", value: user.identifier)
            .limit(1)
            .execute()

        let data = newUser.data
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let dataUser = try decoder.decode([dbAdmin].self, from: data)
        print(dataUser)

        if dataUser.first == nil {
            return false
        } else {
            return true
        }
    }
    
    public func getActiveUserData(user: User) async throws -> databaseUser? {
        guard let client = SupabaseManager.sharedInstance.client else { return nil }

        let newUser = try await client.database
            .from("Users")
            .select()
            .eq("email", value: user.email)
            .limit(1)
            .execute()

        let data = newUser.data
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let dataUser = try decoder.decode([databaseUser].self, from: data)
        print(dataUser)

        if dataUser.first == nil {
            throw DatabaseError.error
        }
        
        return dataUser.first
    }
    
    public func authenticate(_ on: AuthService, _ method: AuthOptions, _ info: AuthObject, completion: @escaping (AuthResponse, SupaUser?) -> ()) {
        guard let client = SupabaseManager.sharedInstance.client, let email = info.email, let password = info.password else { return }
        switch method {
        case .signup:
            Task {
              do {
                  let response = try await client.auth.signUp(email: email, password: password)

                  let user = SupaUser(id: response.user.id, email: response.user.email ?? "")
                  
                  completion(.success, user)
//                  let session = try await client.auth.session
//                  print("### Session Info: \(session)")
              } catch {
                  print("### Sign Up Error: \(error)")
                  completion(.error, nil)
              }
            }
        case .signin:
            Task {
                do {
                    let response = try await client.auth.signIn(email: email, password: password)
                    
                    let user = SupaUser(id: response.user.id, email: response.user.email ?? "")
                    completion(.success, user)

//                    let session = try await client.auth.session
                } catch {
                    completion(.error, nil)
                }
            }

        }
    }

    private func awaitCreateUser(user: DbUser) async throws -> databaseUser? {
        guard let client = SupabaseManager.sharedInstance.client else { return nil }

        try await client.database
            .from("Users")
            .insert(user)
//                    .select()
        // specify you want a single value returned, otherwise it returns a list.
            .execute()

        let newUser = try await client.database
            .from("Users")
            .select()
//                    .match(["user_id": user.user_id.uuidString.lowercased()])
            .eq("identifier", value: user.identifier.uuidString.lowercased())
            .limit(1)
            .execute()

        let data = newUser.data
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let dataUser = try decoder.decode([databaseUser].self, from: data)
        print(dataUser)

        if dataUser.first == nil {
            throw DatabaseError.error
        }
        return dataUser.first
    }

    public func createNewUser(user: DbUser, completion: @escaping (UUID?) -> ()) {
//        guard let client = SupabaseManager.sharedInstance.client else { return }
        Task {
            do {
                let newUser = try await awaitCreateUser(user: user)
                self.authenticatedUser = NewBMUser(id: newUser?.identifier ?? UUID(), username: newUser?.username ?? "", firstName: newUser?.firstName ?? "", lastName: newUser?.lastName ?? "", email: newUser?.email ?? "", bio: "", website: "", showFullName: false, avatar: "", posts: [])
                completion(newUser?.identifier)
            } catch {
                print("Wrongggg")
                completion(nil)
            }
        }
    }

    private func awaitUpdateUser(user: DbUser) async throws {
        guard let client = SupabaseManager.sharedInstance.client else { return }

        let params: [String: String] = ["username": user.username, "firstName": user.firstName, "lastName": user.lastName, "email": user.email, "bio": user.bio, "website": user.website, "avatar": user.avatar]

        try await client.database
            .from("Users")
            .update(params)
            .eq("identifier", value: user.identifier.uuidString.lowercased())
            .execute()
    }

    private func awaitUpdateUserShowFullName(user: DbUser) async throws {
        guard let client = SupabaseManager.sharedInstance.client else { return }

        let params: [String: Bool] = ["showFullName": user.showFullName]

        try await client.database
            .from("Users")
            .update(params)
            .eq("identifier", value: user.identifier.uuidString.lowercased())
            .execute()
    }

    private func updateUser(user: DbUser, completion: @escaping (Bool) -> ()) {
        Task {
            do {
                try await awaitUpdateUser(user: user)
                try await awaitUpdateUserShowFullName(user: user)
                completion(true)
            } catch {
                print("Wrongggg")
                completion(false)
            }
        }
    }

    public func updateUser(user: DbUser, completion: @escaping (NewBMUser?) -> ()) {
        self.updateUser(user: user, completion: { comp in
            if comp {
                let authUser = NewBMUser(id: user.identifier, username: user.username, firstName: user.firstName, lastName: user.lastName, email: user.email, bio: user.bio, website: user.website, showFullName: user.showFullName, avatar: user.avatar, posts: user.posts)
                self.authenticatedUser = authUser
                completion(authUser)
            } else {

            }
        })
    }
    
    public func signOut(completion: @escaping (Bool) -> ()) {
        SupabaseManager.sharedInstance.signOut(completion: { didSignOut in
            completion(didSignOut)
        })
    }
}
