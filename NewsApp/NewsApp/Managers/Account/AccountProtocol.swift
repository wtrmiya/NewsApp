//
//  AccountProtocol.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/07.
//

import Foundation

protocol AccountProtocol: AnyObject {
    func signUp(email: String, password: String, displayName: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() throws
    func setUserDataStoreDocumentIdToCurrentUser(userDataStoreDocumentId: String)
    func updateDisplayName(displayName: String) async throws
    func updateEmail(currentEmail: String, password: String, newEmail: String) async throws
    func deleteAccount(email: String, password: String) async throws
    
    var isSignedIn: Bool { get }
    var userAccount: UserAccount? { get set }
}
