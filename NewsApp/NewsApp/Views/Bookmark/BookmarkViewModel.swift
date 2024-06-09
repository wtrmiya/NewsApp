//
//  BookmarkViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/09.
//

import Foundation

final class BookmarkViewModel: ObservableObject {
    let accountManager: AccountProtocol
    
    init(accountManager: AccountProtocol = AccountManager.shared) {
        self.accountManager = accountManager
    }
    
    var isSignedIn: Bool {
        accountManager.isSignedIn
    }
}
