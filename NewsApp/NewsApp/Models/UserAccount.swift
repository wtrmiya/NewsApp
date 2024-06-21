//
//  UserAccount.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation

struct UserAccount: Hashable {
    private(set) var uid: String
    private(set) var email: String
    private(set) var displayName: String
    private(set) var documentId: String?
    
    mutating func setDocumentId(documentId: String) {
        self.documentId = documentId
    }
}
