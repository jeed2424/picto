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

    public var authenticatedUser: NewBMUser?

    public init () {}
    
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

    public func awaitCreateUser(user: DbUser) async throws -> databaseUser? {
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

//        print("\(newUser.users.first?.firstName)")
//        completion(newUser.users.first?.identifier)
    }

    public func createNewUser(user: DbUser, completion: @escaping (UUID?) -> ()) {
//        guard let client = SupabaseManager.sharedInstance.client else { return }
        Task {
            do {
                let newUser = try await awaitCreateUser(user: user)
                self.authenticatedUser = NewBMUser(id: newUser?.identifier ?? UUID(), username: newUser?.username ?? "", firstName: newUser?.firstName ?? "", lastName: newUser?.lastName ?? "", email: newUser?.email ?? "")
                completion(newUser?.identifier)
//                try await client.database
//                    .from("Users")
//                    .insert(user)
////                    .select()
//                // specify you want a single value returned, otherwise it returns a list.
//                    .execute()
//
//
//                let newUser: databaseUsers = try await client.database
//                    .from("Users")
//                    .select()
////                    .match(["user_id": user.user_id.uuidString.lowercased()])
//                    .eq("identifier", value: user.identifier.uuidString.lowercased())
//                    .limit(1)
//                    .execute()
//                    .value
//
//                print("\(newUser.users.first?.firstName)")
//                completion(newUser.users.first?.identifier)
//                    .value
//                completion(UUID())

//                if let newUser = user.first(where: { $0.id == user.user_id }) {
//                    self.authenticatedUser = NewBMUser(id: newUser.id, username: newUser.username, firstName: newUser.firstName, lastName: newUser.lastName, email: newUser.email)
//                    print("Done")
//                    completion(newUser.id)
//                } else {
//                    print("Error getting user data")
//                    completion(nil)
//                }
            } catch {
                print("Wrongggg")
                completion(nil)
            }
        }

//        Task {
//            do {
//                let newUser = try await client.database
//                    .from("Users")
//                    .select("user_id")
////                    .match(["user_id": user.user_id.uuidString.lowercased()])
//                    .eq("user_id", value: user.user_id.uuidString.lowercased())
//                    .execute()
//
//                print("\(newUser.data)")
////                self.authenticatedUser = NewBMUser(id: newUser.id, username: newUser.username, firstName: newUser.firstName, lastName: newUser.lastName, email: newUser.email)
////                completion(newUser.id)
//            } catch {
//                completion(nil)
//            }
//        }
    }
}
