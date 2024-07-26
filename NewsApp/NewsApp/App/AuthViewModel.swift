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
    
    @Published var signedInUserAccount: UserAccount?
    
    @Published var errorMessage: String?

    private let accountManager: AccountProtocol
    private let userSettingsManager: UserSettingsManagerProtocol
    private let userDataStoreManager: UserDataStoreManagerProtocol
    private let pushNotificationManager: PushNotificationManager

    init(accountManager: AccountProtocol,
         userSettingsManager: UserSettingsManagerProtocol,
         userDataStoreManager: UserDataStoreManagerProtocol,
         pushNotificationManager: PushNotificationManager
    ) {
        self.accountManager = accountManager
        self.userSettingsManager = userSettingsManager
        self.userDataStoreManager = userDataStoreManager
        self.pushNotificationManager = pushNotificationManager

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
            guard let tempUserAccount = accountManager.userAccount else { return }
            let userDataStoreDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(
                userAccount: tempUserAccount
            )
            accountManager.setUserDataStoreDocumentIdToCurrentUser(userDataStoreDocumentId: userDataStoreDocumentId)
            guard let userAccount = accountManager.userAccount else { return }
            try await userSettingsManager.fetchCurrentUserSettings(userAccount: userAccount)
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
            guard let tempUserAccount = accountManager.userAccount else { return }
            try await userDataStoreManager.createUserDataStore(userAccount: tempUserAccount)
            let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(userAccount: tempUserAccount)
            accountManager.setUserDataStoreDocumentIdToCurrentUser(userDataStoreDocumentId: userDocumentId)
            guard let userAccount = accountManager.userAccount else { return }
            try await userSettingsManager.createDefaultUserSettings(userAccount: userAccount)
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
            pushNotificationManager.cancelAllScheduledPushNotifications()
            try accountManager.signOut()
        } catch {
            print(error)
        }
    }
    
    @objc func userStateChanged(notification: Notification) {
        let userAccount = notification.userInfo?["user"] as? UserAccount
        Task {
            await MainActor.run {
                self.signedInUserAccount = userAccount
            }
        }
    }
}
