//
//  UserSettingsManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserSettingsManager {
    static let shared = UserSettingsManager()
    private init() {}
    private var userSettings: UserSettings? {
        didSet {
            print(userSettings.debugDescription)
        }
    }
}

extension UserSettingsManager: UserSettingsManagerProtocol {
    var currentUserSettings: UserSettings {
        if let userSettings {
            return userSettings
        } else {
            return UserSettings.defaultSettingsWithDummyUID()
        }
    }
    
    func createDefaultUserSettings(user: UserAccount) async throws {
        let firestoreDB = Firestore.firestore()
        let defaultSettings = UserSettings.defaultSettings(uid: user.uid)
        let defaultSettingsDict = defaultSettings.toDictionary()
        try await firestoreDB.collection("user_settings").addDocument(data: defaultSettingsDict)
        self.userSettings = defaultSettings
    }

    func getCurrentUserSettings(user: UserAccount) async throws {
        let firestoreDB = Firestore.firestore()
        guard let snapshot = try await firestoreDB.collection("user_settings")
            .whereField("uid", isEqualTo: user.uid)
            .getDocuments().documents.first
        else {
            print("\(#function) #1")
            return
        }
        
        let currentUserSettings = UserSettings.fromSnapshot(snapshot: snapshot)
        self.userSettings = currentUserSettings
    }
    
    func updateUserSettings(by updatedUserSettings: UserSettings) async throws {
        let firestoreDB = Firestore.firestore()
        guard let userSettingsDocumentID = try await firestoreDB.collection("user_settings")
            .whereField("uid", isEqualTo: updatedUserSettings.uid)
            .getDocuments().documents.first?.documentID
        else { return }
        
        let docRef = firestoreDB.collection("user_settings").document(userSettingsDocumentID)
        try await docRef.updateData(updatedUserSettings.toDictionary())
    }
    
    func removeCurrentUserSettings() {
        self.userSettings = nil
    }
}
