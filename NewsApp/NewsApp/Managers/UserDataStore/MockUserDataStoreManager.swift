//
//  MockUserDataStoreManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/18.
//

import Foundation

final class MockUserDataStoreManager: UserDataStoreManagerProtocol {
    func createUserDataStore(user: UserAccount) async throws {}
    
    func getUserDataStoreDocumentId(user: UserAccount) async throws -> String {
        return UUID().uuidString
    }
}