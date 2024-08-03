//
//  AuthViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/21.
//

import Foundation
import UserNotifications

enum AuthViewModelError: Error {
    case noUserAccount
}

final class AuthViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordRepeated: String = ""
    
    @Published var signedInUserAccount: UserAccount?
    
    @Published var errorMessage: String?

    private let accountManager: AccountManagerProtocol
    private let userSettingsManager: UserSettingsManagerProtocol
    private let userDataStoreManager: UserDataStoreManagerProtocol
    private let pushNotificationManager: PushNotificationManager

    init(accountManager: AccountManagerProtocol,
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
            guard let tempUserAccount = accountManager.userAccount else {
                throw AuthViewModelError.noUserAccount
            }
            let userDataStoreDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(
                userAccount: tempUserAccount
            )
            try accountManager.setUserDataStoreDocumentIdToCurrentUser(userDataStoreDocumentId: userDataStoreDocumentId)
            guard let userAccount = accountManager.userAccount else {
                throw AuthViewModelError.noUserAccount
            }
            try await userSettingsManager.fetchCurrentUserSettings(userAccount: userAccount)
        } catch {
            self.errorMessage = "error: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func signUp() async {
        do {
            try await accountManager.signUp(email: email, password: password, displayName: displayName)
            guard let tempUserAccount = accountManager.userAccount else {
                throw AuthViewModelError.noUserAccount
            }
            try await userDataStoreManager.createUserDataStore(userAccount: tempUserAccount)
            let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(userAccount: tempUserAccount)
            try accountManager.setUserDataStoreDocumentIdToCurrentUser(userDataStoreDocumentId: userDocumentId)
            guard let userAccount = accountManager.userAccount else {
                throw AuthViewModelError.noUserAccount
            }
            try await userSettingsManager.createDefaultUserSettings(userAccount: userAccount)
        } catch {
            self.errorMessage = "error: \(error.localizedDescription)"
        }
    }
    
    func signOut() {
        do {
            pushNotificationManager.cancelAllScheduledPushNotifications()
            try accountManager.signOut()
        } catch {
            self.errorMessage = "error: \(error.localizedDescription)"
        }
    }
    
    @objc func userStateChanged(notification: Notification) {
        do {
            if let userAccount = notification.userInfo?["user"] as? UserAccount {
                Task {
                    await MainActor.run {
                        self.signedInUserAccount = userAccount
                    }
                }
            } else {
                throw AuthViewModelError.noUserAccount
            }
        } catch {
            self.errorMessage = "error: \(error.localizedDescription)"
        }
    }
}
