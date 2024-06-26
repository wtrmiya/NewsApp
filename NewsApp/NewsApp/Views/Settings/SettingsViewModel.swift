//
//  SettingsViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var userSettings: UserSettings = UserSettings.defaultSettingsWithDummyUID() {
        didSet {
            print("SettingsViewModel: userSettings: \(userSettings)")
        }
    }
    
    private let accountManager: AccountProtocol
    private let userSettingsManager: UserSettingsManagerProtocol
    
    private var allCancellables = Set<AnyCancellable>()
    
    init(
        accountManager: AccountProtocol,
        userSettingsManager: UserSettingsManagerProtocol
    ) {
        self.accountManager = accountManager
        self.userSettingsManager = userSettingsManager
        
        bindUserSettings()
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
    
    private func bindUserSettings() {
        $userSettings
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSettings in
                guard let self else { return }
                Task {
                    await self.updatePushSettings(
                        morning: newSettings.pushMorningEnabled,
                        afternoon: newSettings.pushAfternoonEnabled,
                        evening: newSettings.pushEveningEnabled
                    )
                }
            }
            .store(in: &allCancellables)
    }
    
    private func updatePushSettings(morning: Bool, afternoon: Bool, evening: Bool) async {
        print("morning: \(morning), afternoon: \(afternoon), evening: \(evening)")
        do {
            guard let user = accountManager.user
            else { return }
            let currentSettings = self.userSettings
            let newSettings = UserSettings(
                uid: currentSettings.uid,
                pushMorningEnabled: morning,
                pushAfternoonEnabled: afternoon,
                pushEveningEnabled: evening,
                letterSize: currentSettings.letterSize,
                letterWeight: currentSettings.letterWeight,
                darkMode: currentSettings.darkMode,
                createdAt: currentSettings.createdAt,
                updatedAt: Date(),
                documentId: user.documentId
            )
            
            try await userSettingsManager.updateUserSettings(by: newSettings, user: user)
        } catch {
            print(error)
        }
    }
}
