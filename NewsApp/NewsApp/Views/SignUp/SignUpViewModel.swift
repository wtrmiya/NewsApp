//
//  SignUpViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/06.
//

import Foundation

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordRepeated: String = ""
    
    @Published var errorMessage: String?
    
    private let accountManager: AccountProtocol
    private let userSettingsManager: UserSettingsManagerProtocol
    private let userDataStoreManager: UserDataStoreManager

    init(accountManager: AccountProtocol = AccountManager.shared,
         userSettingsManager: UserSettingsManagerProtocol = UserSettingsManager.shared,
         userDataStoreManager: UserDataStoreManager = UserDataStoreManager.shared
    ) {
        self.accountManager = accountManager
        self.userSettingsManager = userSettingsManager
        self.userDataStoreManager = userDataStoreManager
    }

    func signUp() async {
        do {
            try await accountManager.signUp(email: email, password: password, displayName: displayName)
            guard let user = accountManager.user else { return }
            try await userDataStoreManager.createUserDataStore(user: user)
            try await userSettingsManager.registerDefaultUserSettings(uid: user.uid)
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
}
