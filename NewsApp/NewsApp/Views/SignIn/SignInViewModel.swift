//
//  SignInViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/08.
//

import Foundation

@MainActor
final class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
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

    func signIn() async {
        do {
            try await accountManager.signIn(email: email, password: password)
            guard let tempUser = accountManager.user else { return }
            let userDocumentId = try await userDataStoreManager.getUserDataStoreDocumentId(user: tempUser)
            accountManager.setDocumentIdToCurrentUser(documentId: userDocumentId)
            guard let user = accountManager.user else { return }
            try await userSettingsManager.getCurrentUserSettings(user: user)
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
