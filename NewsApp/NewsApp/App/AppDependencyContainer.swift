//
//  AppDependencyContainer.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation
import SwiftUI

final class AppDependencyContainer: ObservableObject {
    private let sharedAccountManager: AccountProtocol
    private let sharedUserSettingsManager: UserSettingsManagerProtocol
    
    init() {
        let accountManager = AccountManager.shared
        let userSettingsManager = UserSettingsManager.shared
        if let user = accountManager.user {
            Task {
                do {
                    try await userSettingsManager.getCurrentUserSettings(uid: user.uid)
                } catch {
                    print(error)
                }
            }
        }
        
        self.sharedAccountManager = accountManager
        self.sharedUserSettingsManager = userSettingsManager
    }
    
    func makeHomeView() -> HomeView {
        return HomeView(homeViewModel: makeHomeViewModel())
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            articleManager: ArticleManager.shared,
            bookmarkManager: BookmarkManager.shared,
            accountManager: sharedAccountManager
        )
    }
    
    func makeBookmarkView() -> BookmarkView {
        return BookmarkView(bookmarkViewModel: makeBookmarkViewModel())
    }
    
    func makeBookmarkViewModel() -> BookmarkViewModel {
        return BookmarkViewModel(
            accountManager: sharedAccountManager,
            bookmarkManager: BookmarkManager.shared
        )
    }
    
    func makeDrawerContentView(isShowing: Binding<Bool>) -> DrawerContentView {
        return DrawerContentView(
            isShowing: isShowing,
            drawerViewModel: makeDrawerViewModel()
        )
    }
    
    func makeDrawerViewModel() -> DrawerViewModel {
        return DrawerViewModel(accountManager: sharedAccountManager)
    }
    
    func makeTermView(isShowing: Binding<Bool>) -> TermView {
        return TermView(
            isShowing: isShowing,
            termViewModel: makeTermViewModel()
        )
    }
    
    func makeTermViewModel() -> TermViewModel {
        return TermViewModel(termManager: TermManager.shared)
    }
    
    func makePushNotificationSettingsView(isShowing: Binding<Bool>) -> PushNotificationSettingsView {
        return PushNotificationSettingsView(
            isShowing: isShowing,
            settingsViewModel: makeSettingsViewModel()
        )
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(
            accountManager: sharedAccountManager,
            userSettingsManager: sharedUserSettingsManager
        )
    }
}
