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
}

extension UserSettingsManager {
    func registerDefaultUserSettings(uid: String) async throws {
        let firestoreDB = Firestore.firestore()
        let defaultSettings = UserSettings.defaultSettings(uid: uid).toDictionary()
        try await firestoreDB.collection("user_settings").addDocument(data: defaultSettings)
    }
}
