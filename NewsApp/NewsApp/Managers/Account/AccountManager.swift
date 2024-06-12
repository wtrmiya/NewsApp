//
//  AccountManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/06.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

final class AccountManager {
    static let shared = AccountManager()
    private init() {
        guard let user = Auth.auth().currentUser,
              let email = user.email,
              let displayName = user.displayName
        else { return }
        self.user = UserAccount(
            uid: user.uid,
            email: email,
            displayName: displayName
        )
    }
    
    var user: UserAccount?
}

extension AccountManager: AccountProtocol {
    var isSignedIn: Bool {
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
    func signUp(email: String, password: String, displayName: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await updateDisplayName(user: result.user, displayName: displayName)
            guard let user = UserAccount(user: result.user) else { return }
            self.user = user
            try await createUserDataToFirestore(user: result.user)
        } catch {
            if let error = error as? AuthErrorCode {
                let errorMessage: String
                switch error.code {
                case .invalidEmail:
                    errorMessage = "invalidEmail"
                case .emailAlreadyInUse:
                    errorMessage = "emailAlreadyInUse"
                case .operationNotAllowed:
                    errorMessage = "operationNotAllowed"
                case .weakPassword:
                    errorMessage = "weakPassword"
                default:
                    errorMessage = "unknownError"
                }
                
                throw AuthError.authError(errorMessage: errorMessage)
            } else {
                throw AuthError.unknownError(errorMessage: error.localizedDescription)
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            guard let user = UserAccount(user: result.user) else { return }
            self.user = user
        } catch {
            if let error = error as? AuthErrorCode {
                let errorMessage: String
                switch error.code {
                case .operationNotAllowed:
                    errorMessage = "operationNotAllowed"
                case .userDisabled:
                    errorMessage = "userDisabled"
                case .wrongPassword:
                    errorMessage = "wrongPassword"
                case .invalidEmail:
                    errorMessage = "invalidEmail"
                default:
                    errorMessage = "unknownError"
                }
                
                throw AuthError.authError(errorMessage: errorMessage)
            } else {
                throw AuthError.unknownError(errorMessage: error.localizedDescription)
            }
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            if let error = error as? AuthErrorCode {
                let errorMessage: String
                switch error.code {
                case .keychainError:
                    errorMessage = "keychainError"
                default:
                    errorMessage = "unknownError"
                }
                
                throw AuthError.authError(errorMessage: errorMessage)
            } else {
                throw AuthError.unknownError(errorMessage: error.localizedDescription)
            }
        }
    }
    
    private func updateDisplayName(user: User, displayName: String) async throws {
        let request = user.createProfileChangeRequest()
        request.displayName = displayName
        try await request.commitChanges()
    }
    
    private func createUserDataToFirestore(user: User) async throws {
        let firestoreDB = Firestore.firestore()
        try await firestoreDB.collection("users").addDocument(data: [
            "uid": user.uid,
            "displayName": user.displayName ?? "no display name"
        ])
    }
}
