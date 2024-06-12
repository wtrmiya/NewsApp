//
//  MockAccountManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/07.
//

import Foundation

final class MockAccountManager: AccountProtocol {
    var users: [String: [String]] = [:]
    var user: UserAccount?
    
    var isSignedIn: Bool {
        if user != nil {
            return true
        } else {
            return false
        }
    }

    func signUp(email: String, password: String, displayName: String) async throws {
        guard email.isValidEmail()
        else {
            throw AuthError.authError(errorMessage: "invalidEmail")
        }
        
        guard password.isStrongPassword()
        else {
            throw AuthError.authError(errorMessage: "weakPassword")
        }
        
        if users.keys.contains(email) {
            throw AuthError.authError(errorMessage: "emailAlreadyInUse")
        }
        
        users[email] = [password, displayName]
        user = UserAccount(
            uid: UUID().uuidString,
            email: email,
            displayName: displayName
        )
    }
    
    func signIn(email: String, password: String) async throws {
        guard email.isValidEmail()
        else {
            throw AuthError.authError(errorMessage: "invalidEmail")
        }
        
        guard let challengeUser = users[email]
        else {
            throw AuthError.authError(errorMessage: "invalidEmail")
        }
        
        if password != challengeUser[0] {
            throw AuthError.authError(errorMessage: "wrongPassword")
        }
        
        let displayName = users[email]![1]
        
        user = UserAccount(
            uid: UUID().uuidString,
            email: email,
            displayName: displayName
        )
    }
    
    func signOut() throws {
        user = nil
    }
}

extension String {
    func isValidEmail() -> Bool {
        // swiftlint:disable:next force_try line_length
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        // swiftlint:disable:previous force_try line_length
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }

    func isStrongPassword() -> Bool {
        return self.count >= 7 ? true : false
    }
}
