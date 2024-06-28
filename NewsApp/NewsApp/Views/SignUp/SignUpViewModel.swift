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
    private let userDataStoreManager: UserDataStoreManagerProtocol

    init(accountManager: AccountProtocol,
         userSettingsManager: UserSettingsManagerProtocol,
         userDataStoreManager: UserDataStoreManagerProtocol
    ) {
        self.accountManager = accountManager
        self.userSettingsManager = userSettingsManager
        self.userDataStoreManager = userDataStoreManager
    }

    func signUp() async {
        do {
            try await accountManager.signUp(email: email, password: password, displayName: displayName)
            guard let tempUser = accountManager.user else { return }
            try await userDataStoreManager.createUserDataStore(user: tempUser)
            let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(user: tempUser)
            accountManager.setUserDataStoreDocumentIdToCurrentUser(userDataStoreDocumentId: userDocumentId)
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
}
