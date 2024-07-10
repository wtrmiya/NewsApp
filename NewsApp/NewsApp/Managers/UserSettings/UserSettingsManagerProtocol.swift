//
//  UserSettingsManagerProtocol.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation

protocol UserSettingsManagerProtocol {
    var currentUserSettings: UserSettings { get }
    func createDefaultUserSettings(userAccount: UserAccount) async throws
    func fetchCurrentUserSettings(userAccount: UserAccount) async throws
    func updateUserSettings(by updatedUserSettings: UserSettings, userAccount: UserAccount) async throws
    func removeCurrentUserSettings()
}
