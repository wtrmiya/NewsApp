//
//  AppDelegate.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AppStateManager.shared.appState = .launching
        
        FirebaseApp.configure()
        
        Task {
            do {
                // PushNotification
                try await PushNotificationManager.shared.requestAuthorization()
                try await PushNotificationManager.shared.setupPushNotifications()
                
                // UsereSettings
                if let tempUser = AccountManager.shared.user {
                    // この時点でユーザのDocumentIdが不明。
                    // UserDataStoreから取得する必要がある。
                    let userDataStoreDocumentId = try await UserDataStoreManager.shared
                        .getUserDataStoreDocumentId(user: tempUser)
                    let user = UserAccount(
                        uid: tempUser.uid,
                        email: tempUser.email,
                        displayName: tempUser.displayName,
                        userDataStoreDocumentId: userDataStoreDocumentId
                    )
                    try await UserSettingsManager.shared.fetchCurrentUserSettings(user: user)
                    AccountManager.shared
                        .setUserDataStoreDocumentIdToCurrentUser(
                            userDataStoreDocumentId: userDataStoreDocumentId
                        )
                } else {
                    AppStateManager.shared.appState = .launchedSignedOut
                }
            } catch {
                print(error)
                AppStateManager.shared.appState = .launchedSignedOut
            }
        }

        return true
    }
}
