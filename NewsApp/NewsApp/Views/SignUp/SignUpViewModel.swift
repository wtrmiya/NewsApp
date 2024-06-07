//
//  SignUpViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/06.
//

import Foundation

final class SignUpViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordRepeated: String = ""
    
    @Published var errorMessage: String?

    func signUp() async {
        do {
            try await AccountManager.shared.signUp(email: email, password: password)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
