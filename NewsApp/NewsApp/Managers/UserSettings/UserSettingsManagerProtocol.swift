//
//  UserSettingsManagerProtocol.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation

protocol UserSettingsManagerProtocol {
    var currentUserSettings: UserSettings { get }
    func registerDefaultUserSettings(uid: String) async throws
    func getCurrentUserSettings(uid: String) async throws
    func updateUserSettings(by updatedUserSettings: UserSettings) async throws
    func removeCurrentUserSettings()
}
