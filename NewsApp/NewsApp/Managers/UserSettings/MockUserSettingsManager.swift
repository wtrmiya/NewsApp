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
    
    func createDefaultUserSettings(userAccount: UserAccount) async throws {}
    
    func fetchCurrentUserSettings(userAccount: UserAccount) async throws {}
    
    func updateUserSettings(by updatedUserSettings: UserSettings, userAccount: UserAccount) async throws {}
    
    func removeCurrentUserSettings() {}
}
