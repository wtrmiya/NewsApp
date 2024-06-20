//
//  DrawerViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/10.
//

import Foundation
import UserNotifications

final class DrawerViewModel: ObservableObject {
    @Published var signedInUser: UserAccount?
    
    private let accountManager: AccountProtocol
    
    init(accountManager: AccountProtocol = AccountManager.shared) {
        self.accountManager = accountManager
        
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(userStateChanged),
                name: Notification.Name.signInStateChanged,
                object: nil
            )
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
    
    @objc func userStateChanged() {
        Task {
            await MainActor.run {
                signedInUser = accountManager.user
            }
        }
    }
}
