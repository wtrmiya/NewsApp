//
//  DrawerViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/10.
//

import Foundation

final class DrawerViewModel: ObservableObject {
    private let accountManager: AccountProtocol
    
    init(accountManager: AccountProtocol = AccountManager.shared) {
        self.accountManager = accountManager
    }
    
    var sidnedInUser: UserAccount? {
        return accountManager.user
    }
    
    func signOut() {
        do {
            try accountManager.signOut()
        } catch {
            print(error)
        }
    }
}
