// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Supabase

public class SupabaseManager {

    public static let sharedInstance = SupabaseManager()

    private(set) var client: SupabaseClient? = nil
    private let supabaseString = Bundle.main.object(forInfoDictionaryKey: "Supabase_URL") as? String ?? ""
    private let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "Supabase_KEY") as? String ?? ""

    private init() {
        initializeClient()
    }
}

public extension SupabaseManager {
    private func initializeClient() {
        guard let supabaseUrl = URL(string: supabaseString) else { return }
        client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
    }

    func getActiveUser(completion: @escaping (User?) -> ()) {
        Task {
            do {
                let user = try await client?.auth.session.user
                completion(user)
            } catch {
                completion(nil)
            }
        }

    }
}


