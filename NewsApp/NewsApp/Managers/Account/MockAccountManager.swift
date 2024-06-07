//
//  MockAccountManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/07.
//

import Foundation

enum CreateUserError: String, Error {
    case authErrorCodeInvalidEmail
    case authErrorCodeEmailAlreadyInUse
    case authErrorCodeOperationNotAllowed
    case authErrorCodeWeakPassword
}

enum SignInError: String, Error {
    case authErrorCodeOperationNotAllowed
    case authErrorCodeUserDisabled
    case authErrorCodeWrongPassword
    case authErrorCodeInvalidEmail
}

final class MockAccountManager: AccountProtocol {
    var users: [String: [String]] = [:]
    
    var user: [String: [String]]?

    func signUp(email: String, password: String, displayName: String) async throws {
        guard email.isValidEmail()
        else {
            throw CreateUserError.authErrorCodeInvalidEmail
        }
        
        guard password.isStrongPassword()
        else {
            throw CreateUserError.authErrorCodeWeakPassword
        }
        
        if users.keys.contains(email) {
            throw CreateUserError.authErrorCodeEmailAlreadyInUse
        }
        
        users[email] = [password, displayName]
        user = [email: [password, displayName]]
    }
    
    func signIn(email: String, password: String) async throws {
        guard email.isValidEmail()
        else {
            throw SignInError.authErrorCodeInvalidEmail
        }
        
        guard let challengeUser = users[email]
        else {
            throw SignInError.authErrorCodeInvalidEmail
        }
        
        if password != challengeUser[0] {
            throw SignInError.authErrorCodeWrongPassword
        }
        
        let displayName = users[email]![1]
        
        user = [email: [password, displayName]]
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
