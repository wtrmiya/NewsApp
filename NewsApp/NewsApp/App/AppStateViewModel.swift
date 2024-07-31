//
//  AppStateViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/07/26.
//

import Foundation
import UserNotifications

enum AppStateViewModelError: Error {
    case noUserAccount
    case notificationWithNoUserAccount
}

final class AppStateViewModel: ObservableObject {
    @Published var appState: AppState?
    
    @Published var errorMessage: String?

    private let appStateManager: AppStateManager

    init(appStateManager: AppStateManager) {
        self.appStateManager = appStateManager

        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(userStateChanged),
                name: Notification.Name.signInStateChanged,
                object: nil
            )
    }
    
    @objc func userStateChanged(notification: Notification) {
        do {
            guard let userInfo = notification.userInfo?["user"]
            else {
                throw AppStateViewModelError.notificationWithNoUserAccount
            }
            
            let userAccount = userInfo as? UserAccount
            Task {
                await MainActor.run {
                    if appStateManager.appState != .launching {
                        if userAccount == nil {
                            appState = .launchedSignedOut
                        } else {
                            appState = .launchedSignedIn
                        }
                    } else {
                        print("App state is .launching. Do nothing.")
                    }
                }
            }
        } catch {
            self.errorMessage = "error: \(error.localizedDescription)"
        }
    }
}
