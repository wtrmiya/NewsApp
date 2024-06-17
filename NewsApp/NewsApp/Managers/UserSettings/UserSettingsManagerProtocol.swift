//
//  UserSettingsManagerProtocol.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation

protocol UserSettingsManagerProtocol {
    var currentUserSettings: UserSettings { get }
    func createDefaultUserSettings(user: UserAccount) async throws
    func getCurrentUserSettings(user: UserAccount) async throws
    func updateUserSettings(by updatedUserSettings: UserSettings) async throws
    func removeCurrentUserSettings()
}
