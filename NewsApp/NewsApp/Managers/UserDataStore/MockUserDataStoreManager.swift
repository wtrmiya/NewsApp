//
//  MockUserDataStoreManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/18.
//

import Foundation

final class MockUserDataStoreManager: UserDataStoreManagerProtocol {
    func createUserDataStore(userAccount: UserAccount) async throws {}
    
    func getUserDataStoreDocumentId(userAccount: UserAccount) async throws -> String {
        return UUID().uuidString
    }
}
