//
//  AccountSettingsViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/15.
//

import Foundation

final class AccountSettingsViewModel: ObservableObject {
    @Published var userAccount: UserAccount?
    
    private let accountManager: AccountProtocol
    
    init(accountManager: AccountProtocol) {
        self.accountManager = accountManager
    }
    
    func populateUserAccount() {
        self.userAccount = accountManager.user
    }
}
