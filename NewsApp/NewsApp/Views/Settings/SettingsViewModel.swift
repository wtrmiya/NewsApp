//
//  SettingsViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var userSettings: UserSettings = UserSettings.defaultSettingsWithDummyUID()
    
    private let accountManager: AccountProtocol
    private let userSettingsManager: UserSettingsManagerProtocol
    
    init(
        accountManager: AccountProtocol = AccountManager.shared,
        userSettingsManager: UserSettingsManagerProtocol = UserSettingsManager.shared
    ) {
        self.accountManager = accountManager
        self.userSettingsManager = userSettingsManager
    }
    
    @MainActor
    func populateUserSettings() async {
        do {
            guard let user = accountManager.user
            else { return }
            try await userSettingsManager.getCurrentUserSettings(uid: user.uid)
            self.userSettings = userSettingsManager.currentUserSettings
        } catch {
            print(error)
        }
    }
}
