//
//  UserAccount.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation
import FirebaseAuth

struct UserAccount {
    private(set) var uid: String
    private(set) var email: String
    private(set) var displayName: String
    
    init(uid: String, email: String, displayName: String) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }
    
    init?(user: User) {
        self.uid = user.uid
        guard let email = user.email,
              let displayName = user.displayName
        else { return nil }
        self.email = email
        self.displayName = displayName
    }
}
