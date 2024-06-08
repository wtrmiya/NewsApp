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
    
    init(accountManager: AccountProtocol = AccountManager.shared) {
        self.accountManager = accountManager
    }

    func signIn() async {
        do {
            try await accountManager.signIn(email: email, password: password)
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
