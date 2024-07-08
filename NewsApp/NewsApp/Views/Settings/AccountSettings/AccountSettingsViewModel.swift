//
//  AccountSettingsViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/15.
//

import Foundation

final class AccountSettingsViewModel: ObservableObject {
    @Published var userAccount: UserAccount?
    @Published var inputDisplayName: String = ""
    @Published var inputEmail: String = ""
    @Published var inputPassword: String = ""

    private let accountManager: AccountProtocol
    
    init(accountManager: AccountProtocol) {
        self.accountManager = accountManager
    }
    
    func populateUserAccount() {
        self.userAccount = accountManager.user
    }
    
    /*
    @MainActor
    func setupInputUserAccount(email: String, displayName: String, password: String) {
        guard let currentUserAccount = userAccount else { return }
        let inputUserAccount = UserAccount(
            uid: currentUserAccount.uid,
            email: email,
            displayName: displayName
        )
        
        self.inputUserAccount = inputUserAccount
        self.inputPassword = password
    }
     */
}
