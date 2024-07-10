//
//  UserDataStoreManagerProtocol.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/18.
//

import Foundation

protocol UserDataStoreManagerProtocol {
    func createUserDataStore(userAccount: UserAccount) async throws
    func getUserDataStoreDocumentId(userAccount: UserAccount) async throws -> String
}
