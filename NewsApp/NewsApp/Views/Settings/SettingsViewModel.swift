//
//  SettingsViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation
import Combine
import UserNotifications

final class SettingsViewModel: ObservableObject {
    @Published var userSettings: UserSettings = UserSettings.defaultSettingsWithDummyUID() {
        didSet {
            if appStateManager.appState == .launching {
                if accountManager.userAccount != nil {
                    appStateManager.appState = .launchedSignedIn
                } else {
                    appStateManager.appState = .launchedSignedOut
                }
            }
        }
    }
    
    private let accountManager: AccountProtocol
    private let userSettingsManager: UserSettingsManagerProtocol
    private let appStateManager: AppStateManager
    private let pushNotificationManager: PushNotificationManager

    private var allCancellables = Set<AnyCancellable>()
    
    init(
        accountManager: AccountProtocol,
        userSettingsManager: UserSettingsManagerProtocol,
        appStateManager: AppStateManager,
        pushNotificationManager: PushNotificationManager
    ) {
        self.accountManager = accountManager
        self.userSettingsManager = userSettingsManager
        self.appStateManager = appStateManager
        self.pushNotificationManager = pushNotificationManager
        
        print("\(#function): NotificationCenter")
        
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(userSettingsChanged),
                name: Notification.Name.userSettingsChanged,
                object: nil
            )
        
        bindUserSettings()
    }
    
    @MainActor
    func populateUserSettings() async {
        print("populateUserSettings")
        do {
            guard let userAccount = accountManager.userAccount
            else { return }
            try await userSettingsManager.fetchCurrentUserSettings(userAccount: userAccount)
            self.userSettings = userSettingsManager.currentUserSettings
            print("fetched userSettings: \(userSettingsManager.currentUserSettings)")
        } catch {
            print(error)
        }
    }
    
    private func bindUserSettings() {
        $userSettings
            .receive(on: DispatchQueue.main)
            .filter({ [weak self] _ in
                guard let self else { return false }
                return appStateManager.appState != .launching
            })
            .dropFirst()
            .sink { [weak self] newSettings in
                guard let self else { return }
                Task {
                    print("updateSetings")
                    await self.updateSettings(inputSettings: newSettings)
                }
            }
            .store(in: &allCancellables)
    }
    
    private func updateSettings(inputSettings: UserSettings) async {
        print("userSettings: \(userSettings)")
        guard self.userSettings.userSettingsDocumentId != nil
        else {
            print("\(#file): \(#function): userSettings.userSettingsDocumentId is nil")
            return
        }
        do {
            guard let userAccount = accountManager.userAccount
            else {
                print("\(#file): \(#function): accountManager.user is nil")
                return
            }
            let currentSettings = self.userSettings
            let newSettings = UserSettings(
                uid: currentSettings.uid,
                pushMorningEnabled: inputSettings.pushMorningEnabled,
                pushAfternoonEnabled: inputSettings.pushAfternoonEnabled,
                pushEveningEnabled: inputSettings.pushAfternoonEnabled,
                letterSize: inputSettings.letterSize,
                letterWeight: inputSettings.letterWeight,
                darkMode: inputSettings.darkMode,
                createdAt: currentSettings.createdAt,
                updatedAt: Date(),
                userSettingsDocumentId: currentSettings.userSettingsDocumentId
            )
            try await pushNotificationManager.applyPushNotificaionSettings(userSettings: newSettings)
            
            if AppStateManager.shared.appState == .launchedSignedIn {
                try await userSettingsManager.updateUserSettings(by: newSettings, userAccount: userAccount)
            }
        } catch {
            print(error)
        }
    }
    
    @objc func userSettingsChanged(notification: Notification) {
        guard let userSettings = notification.userInfo?["user_settings"] as? UserSettings else {
            return
        }
        Task {
            await MainActor.run {
                self.userSettings = userSettings
            }
        }
    }
}
