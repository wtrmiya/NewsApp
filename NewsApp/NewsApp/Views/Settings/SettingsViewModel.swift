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
            print("SettingsViewModel: didSet userSettings: \(userSettings)")
            if appStateManager.appState == .launching {
                appStateManager.appState = .launched
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
            .receive(on: DispatchQueue.main)
            .filter({ [weak self] _ in
                guard let self else { return false }
                return appStateManager.appState == .launched
            })
            .dropFirst()
            .sink { [weak self] newSettings in
                guard let self else { return }
                Task {
                    print("updatePushSetings")
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
        guard self.userSettings.userSettingsDocumentId != nil
        else {
            print("\(#file): \(#function): userSettings.userSettingsDocumentId is nil")
            return
        }
        do {
            guard let user = accountManager.user
            else {
                print("\(#file): \(#function): accountManager.user is nil")
                return
            }
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
                userSettingsDocumentId: currentSettings.userSettingsDocumentId
            )
            try await pushNotificationManager.applyPushNotificaionSettings(userSettings: newSettings)
            try await userSettingsManager.updateUserSettings(by: newSettings, user: user)
        } catch {
            print(error)
        }
    }
    
    @objc func userSettingsChanged(notification: Notification) {
        guard appStateManager.appState == .launching else {
            print("\(#function) userSettings changed but now not launching")
            return
        }
        guard let userSettings = notification.userInfo?["user_settings"] as? UserSettings else {
            print("\(#function) route #2")
            return
        }
        Task {
            await MainActor.run {
                print("\(#function) route #3")
                self.userSettings = userSettings
            }
        }
    }
}
