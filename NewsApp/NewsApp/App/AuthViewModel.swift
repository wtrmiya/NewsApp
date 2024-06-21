//
//  AuthViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/21.
//

import Foundation
import UserNotifications

final class AuthViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordRepeated: String = ""
    
    @Published var signedInUser: UserAccount? {
        didSet {
            print("\(#file): \(#function): signedInUser: \(signedInUser)")
        }
    }

    @Published var errorMessage: String?

    private let accountManager: AccountProtocol
    private let userSettingsManager: UserSettingsManagerProtocol
    private let userDataStoreManager: UserDataStoreManagerProtocol
    
    init(accountManager: AccountProtocol,
         userSettingsManager: UserSettingsManagerProtocol,
         userDataStoreManager: UserDataStoreManagerProtocol
    ) {
        self.accountManager = accountManager
        self.userSettingsManager = userSettingsManager
        self.userDataStoreManager = userDataStoreManager
        
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(userStateChanged),
                name: Notification.Name.signInStateChanged,
                object: nil
            )
    }
    
    @MainActor
    func signIn() async {
        do {
            try await accountManager.signIn(email: email, password: password)
            guard let tempUser = accountManager.user else { return }
            let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(user: tempUser)
            accountManager.setDocumentIdToCurrentUser(documentId: userDocumentId)
            guard let user = accountManager.user else { return }
            try await userSettingsManager.fetchCurrentUserSettings(user: user)
        } catch {
            if let error = error as? AuthError {
                switch error {
                case .authError(let errorMessage):
                    self.errorMessage = errorMessage
                case .unknownError(let errorMessage):
                    self.errorMessage = errorMessage
                }
            } else {
                errorMessage = "Sorry, something wrong. error: \(error.localizedDescription)"
            }
        }
    }
    
    @MainActor
    func signUp() async {
        do {
            try await accountManager.signUp(email: email, password: password, displayName: displayName)
            guard let tempUser = accountManager.user else { return }
            try await userDataStoreManager.createUserDataStore(user: tempUser)
            let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(user: tempUser)
            accountManager.setDocumentIdToCurrentUser(documentId: userDocumentId)
            guard let user = accountManager.user else { return }
            try await userSettingsManager.createDefaultUserSettings(user: user)
        } catch {
            if let error = error as? AuthError {
                switch error {
                case .authError(let errorMessage):
                    self.errorMessage = errorMessage
                case .unknownError(let errorMessage):
                    self.errorMessage = errorMessage
                }
            } else {
                errorMessage = "Sorry, something wrong. error: \(error.localizedDescription)"
            }
        }
    }
    
    func signOut() {
        do {
            try accountManager.signOut()
        } catch {
            print(error)
        }
    }
    
    @objc func userStateChanged(notification: Notification) {
        print("\(#file): \(#function)")
        let user = notification.userInfo?["user"] as? UserAccount
        Task {
            await MainActor.run {
                self.signedInUser = user
            }
        }
    }
}
