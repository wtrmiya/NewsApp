//
//  AccountManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/06.
//

import Foundation
import FirebaseAuth

final class AccountManager {
    static let shared = AccountManager()
    private init() {}
    
    var user: User?
    
    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.user = result.user
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.user = result.user
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        self.user = nil
    }
}