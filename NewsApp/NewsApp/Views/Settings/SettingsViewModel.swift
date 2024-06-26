//
//  SettingsViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var userSettings: UserSettings = UserSettings.defaultSettingsWithDummyUID() {
        didSet {
            Task {
                await updateUserSettings()
            }
        }
    }
    
    private let accountManager: AccountProtocol
    private let userSettingsManager: UserSettingsManagerProtocol
    
    init(
        accountManager: AccountProtocol,
        userSettingsManager: UserSettingsManagerProtocol
    ) {
        self.accountManager = accountManager
        self.userSettingsManager = userSettingsManager
    }
    
    @MainActor
    func populateUserSettings() async {
        do {
            guard let user = accountManager.user
            else { return }
            try await userSettingsManager.fetchCurrentUserSettings(user: user)
            self.userSettings = userSettingsManager.currentUserSettings
        } catch {
            print(error)
        }
    }
    
    private func updateUserSettings() async {
        do {
            guard let user = accountManager.user
            else { return }
            try await userSettingsManager.updateUserSettings(by: self.userSettings, user: user)
        } catch {
            print(error)
        }
    }
}
