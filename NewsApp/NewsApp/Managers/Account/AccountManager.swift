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
import UserNotifications

final class AccountManager {
    static let shared = AccountManager()
    private init() {
        if authStateHander == nil {
            authStateHander = Auth.auth().addStateDidChangeListener({ [weak self] _, user in
                print("\(#function): Listener called")
                guard let self else { return }
                
                self.user = user
                
                if let user {
                    guard let email = user.email,
                          let displayName = user.displayName
                    else { return }
                    
                    self.userAccount = UserAccount(
                        uid: user.uid,
                        email: email,
                        displayName: displayName
                    )
                } else {
                    self.userAccount = nil
                }
            })
        }
    }
    
    private var authStateHander: AuthStateDidChangeListenerHandle?
    
    var userAccount: UserAccount? {
        didSet {
            if oldValue == nil && userAccount != nil {
                postNotification()
            } else if oldValue != nil && userAccount == nil {
                postNotification()
            }
        }
    }
    
    private func postNotification() {
        NotificationCenter.default.post(
            name: Notification.Name.signInStateChanged,
            object: nil,
            userInfo: ["user": userAccount as Any]
        )
    }
    
    private var user: User?
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
            self.user = result.user
            try await updateDisplayName(displayName: displayName)
            self.userAccount = UserAccount(uid: result.user.uid, email: email, displayName: displayName)
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
            self.user = result.user
            guard let displayName = result.user.displayName else { return }
            self.userAccount = UserAccount(uid: result.user.uid, email: email, displayName: displayName)
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
            self.userAccount = nil
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
    
    func updateDisplayName(displayName: String) async throws {
        guard let user else { return }
        let request = user.createProfileChangeRequest()
        request.displayName = displayName
        try await request.commitChanges()
    }
    
    func updateEmail(currentEmail: String, password: String, newEmail: String) async throws {
        guard let user else { return }
        let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: password)
        // reauthenticate
        try await user.reauthenticate(with: credential)
        
        // update email
        try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
    }
    
    func deleteAccount(email: String, password: String) async throws {
        guard let user else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        // reauthenticate
        try await user.reauthenticate(with: credential)
        try await user.delete()
    }

    func setUserDataStoreDocumentIdToCurrentUser(userDataStoreDocumentId: String) {
        self.userAccount?.setUserDataStoreDocumentId(userDataStoreDocumentId: userDataStoreDocumentId)
    }
}
