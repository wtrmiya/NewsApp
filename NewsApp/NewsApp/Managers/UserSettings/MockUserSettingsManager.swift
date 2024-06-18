//
//  MockUserSettingsManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/18.
//

import Foundation

final class MockUserSettingsManager: UserSettingsManagerProtocol {
    var currentUserSettings: UserSettings {
        return UserSettings.defaultSettingsWithDummyUID()
    }
    
    func createDefaultUserSettings(user: UserAccount) async throws {}
    
    func fetchCurrentUserSettings(user: UserAccount) async throws {}
    
    func updateUserSettings(by updatedUserSettings: UserSettings, user: UserAccount) async throws {}
    
    func removeCurrentUserSettings() {}
}
