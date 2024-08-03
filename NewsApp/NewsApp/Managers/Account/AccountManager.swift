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

enum AccountManagerError: Error {
    case invalidEmail
    case emailAlreadyInUse
    case operationNotAllowed
    case weakPassword
    case unknownAuthError
    case unknownError
    case noDisplayName
    case userDisabled
    case wrongPassword
    case keyChainError
    case userIsNil
    case errorInCommittingChanges
    case invalidCredential
    case userMismatch
    case errorInSendingEmailVerification
    case requiresRecentLogin
    case userAccountIsNil
}

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

extension AccountManager: AccountManagerProtocol {
    var isSignedIn: Bool {
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
    /// サインアップする
    ///
    /// - throws: AccountManagerError
    ///
    /// ```
    /// # AccountManagerError
    /// - invalidEmail
    /// - emailAlreadyInUse
    /// - operationNotAllowed
    /// - weakPassword
    /// - unknownAuthError
    /// - unknownError
    /// ```
    func signUp(email: String, password: String, displayName: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            try await updateDisplayName(displayName: displayName)
            self.userAccount = UserAccount(uid: result.user.uid, email: email, displayName: displayName)
        } catch {
            if let error = error as? AuthErrorCode {
                switch error.code {
                case .invalidEmail:
                    throw AccountManagerError.invalidEmail
                case .emailAlreadyInUse:
                    throw AccountManagerError.emailAlreadyInUse
                case .operationNotAllowed:
                    throw AccountManagerError.operationNotAllowed
                case .weakPassword:
                    throw AccountManagerError.weakPassword
                default:
                    throw AccountManagerError.unknownAuthError
                }
            } else {
                throw AuthError.unknownError(errorMessage: error.localizedDescription)
            }
        }
    }
    
    /// サインインする
    ///
    /// - throws: AccountManagerError
    ///
    /// ```
    /// # AccountManagerError
    /// - operationNotAllowed
    /// - userDisabled
    /// - wrongPassword
    /// - invalidEmail
    /// - unknownAuthError
    /// - unknownError
    /// ```
    func signIn(email: String, password: String) async throws {
        let result: AuthDataResult
        do {
            result = try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            if let error = error as? AuthErrorCode {
                switch error.code {
                case .operationNotAllowed:
                    throw AccountManagerError.operationNotAllowed
                case .userDisabled:
                    throw AccountManagerError.userDisabled
                case .wrongPassword:
                    throw AccountManagerError.wrongPassword
                case .invalidEmail:
                    throw AccountManagerError.invalidEmail
                default:
                    throw AccountManagerError.unknownAuthError
                }
            } else {
                throw AccountManagerError.unknownError
            }
        }
        
        self.user = result.user
        guard let displayName = result.user.displayName
        else {
            throw AccountManagerError.noDisplayName
        }
        self.userAccount = UserAccount(uid: result.user.uid, email: email, displayName: displayName)
    }
    
    /// サインアウトする
    ///
    /// - throws: AccountManagerError
    ///
    /// ```
    /// # AccountManagerError
    /// - keyChainError
    /// - unknownAuthError
    /// - unknownError
    /// ```
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.userAccount = nil
        } catch {
            if let error = error as? AuthErrorCode {
                switch error.code {
                case .keychainError:
                    throw AccountManagerError.keyChainError
                default:
                    throw AccountManagerError.unknownAuthError
                }
            } else {
                throw AccountManagerError.unknownError
            }
        }
    }
    
    /// display nameを更新する
    ///
    /// - throws: AccountManagerError
    ///
    /// ```
    /// # AccountManagerError
    /// - userIsNil
    /// - errorInCommittingChanges
    /// ```
    func updateDisplayName(displayName: String) async throws {
        guard let user
        else {
            throw AccountManagerError.userIsNil
        }
        let request = user.createProfileChangeRequest()
        request.displayName = displayName
        do {
            try await request.commitChanges()
        } catch {
            print(error)
            throw AccountManagerError.errorInCommittingChanges
        }
    }
    
    /// Emailアドレスを更新する
    ///
    /// - throws: AccountManagerError
    ///
    /// ```
    /// # AccountManagerError
    /// - userIsNil
    /// - invalidCredential
    /// - operationNotAllowed
    /// - emailAlreadyInUse
    /// - userDisabled
    /// - wrongPassword
    /// - userMismatch
    /// - invalidEmail
    /// - unknownAuthError
    /// - unknownError
    /// - errorInSendingEmailVerification
    /// ```
    func updateEmail(currentEmail: String, password: String, newEmail: String) async throws {
        guard let user
        else {
            throw AccountManagerError.userIsNil
        }
        let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: password)
        // reauthenticate
        do {
            try await user.reauthenticate(with: credential)
        } catch {
            print(error)
            if let error = error as? AuthErrorCode {
                switch error.code {
                case .invalidCredential:
                    throw AccountManagerError.invalidCredential
                case .operationNotAllowed:
                    throw AccountManagerError.operationNotAllowed
                case .emailAlreadyInUse:
                    throw AccountManagerError.emailAlreadyInUse
                case .userDisabled:
                    throw AccountManagerError.userDisabled
                case .wrongPassword:
                    throw AccountManagerError.wrongPassword
                case .userMismatch:
                    throw AccountManagerError.userMismatch
                case .invalidEmail:
                    throw AccountManagerError.invalidEmail
                default:
                    throw AccountManagerError.unknownAuthError
                }
            } else {
                throw AccountManagerError.unknownError
            }
        }
        
        do {
            // update email
            try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
        } catch {
            print(error)
            throw AccountManagerError.errorInSendingEmailVerification
        }
    }
    
    /// アカウントを削除する
    ///
    /// - throws: AccountManagerError
    ///
    /// ```
    /// # AccountManagerError
    /// - userIsNil
    /// - invalidCredential
    /// - operationNotAllowed
    /// - emailAlreadyInUse
    /// - userDisabled
    /// - wrongPassword
    /// - userMismatch
    /// - invalidEmail
    /// - unknownAuthError
    /// - unknownError
    /// - requiresRecentLogin
    /// - unknownAuthError
    /// - unknownError
    /// ```
    func deleteAccount(email: String, password: String) async throws {
        guard let user
        else {
            throw AccountManagerError.userIsNil
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        do {
            // reauthenticate
            try await user.reauthenticate(with: credential)
        } catch {
            print(error)
            if let error = error as? AuthErrorCode {
                switch error.code {
                case .invalidCredential:
                    throw AccountManagerError.invalidCredential
                case .operationNotAllowed:
                    throw AccountManagerError.operationNotAllowed
                case .emailAlreadyInUse:
                    throw AccountManagerError.emailAlreadyInUse
                case .userDisabled:
                    throw AccountManagerError.userDisabled
                case .wrongPassword:
                    throw AccountManagerError.wrongPassword
                case .userMismatch:
                    throw AccountManagerError.userMismatch
                case .invalidEmail:
                    throw AccountManagerError.invalidEmail
                default:
                    throw AccountManagerError.unknownAuthError
                }
            } else {
                throw AccountManagerError.unknownError
            }
        }
        
        // AuthErrorCodeRequiresRecentLogin
        do {
            try await user.delete()
        } catch {
            print(error)
            if let error = error as? AuthErrorCode {
                switch error.code {
                case .requiresRecentLogin:
                    throw AccountManagerError.requiresRecentLogin
                default:
                    throw AccountManagerError.unknownAuthError
                }
            } else {
                throw AccountManagerError.unknownError
            }
        }
    }

    /// UserDataStoreDocumentIdを現在のUserAccountに設定する
    ///
    /// - throws: AccountManagerError
    ///
    /// ```
    /// # AccountManagerError
    /// - userIsNil
    /// ```
    func setUserDataStoreDocumentIdToCurrentUser(userDataStoreDocumentId: String) throws {
        if self.userAccount == nil {
            throw AccountManagerError.userAccountIsNil
        } else {
            self.userAccount?.setUserDataStoreDocumentId(userDataStoreDocumentId: userDataStoreDocumentId)
        }
    }
}
