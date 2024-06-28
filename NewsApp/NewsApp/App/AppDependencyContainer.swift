//
//  AppDependencyContainer.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation
import SwiftUI

@MainActor
final class AppDependencyContainer: ObservableObject {
    private let sharedAccountManager: AccountProtocol
    private let sharedUserSettingsManager: UserSettingsManagerProtocol
    private let sharedArticleManger: ArticleManagerProtocol
    private let sharedAppStateManager: AppStateManager
    private let sharedAccountSettingsViewModel: AccountSettingsViewModel
    private let sharedAuthViewModel: AuthViewModel
    private let sharedHomeViewModel: HomeViewModel
    private let sharedSettingsViewModel: SettingsViewModel

    init() {
        self.sharedAccountManager = AccountManager.shared
        self.sharedUserSettingsManager = UserSettingsManager.shared
        self.sharedArticleManger = ArticleManager.shared
        self.sharedAppStateManager = AppStateManager.shared
        
        self.sharedAccountSettingsViewModel = AccountSettingsViewModel(
            accountManager: sharedAccountManager
        )
        
        self.sharedAuthViewModel = AuthViewModel(
            accountManager: sharedAccountManager,
            userSettingsManager: sharedUserSettingsManager,
            userDataStoreManager: UserDataStoreManager.shared
        )
        
        self.sharedHomeViewModel = HomeViewModel(
            articleManager: sharedArticleManger,
            bookmarkManager: BookmarkManager.shared,
            accountManager: sharedAccountManager,
            userDataSoreManager: UserDataStoreManager.shared
        )
        
        self.sharedSettingsViewModel = SettingsViewModel(
            accountManager: sharedAccountManager,
            userSettingsManager: sharedUserSettingsManager,
            appStateManager: sharedAppStateManager
        )
    }
    
    func makeContentView() -> ContentView {
        return ContentView(
            authViewModel: sharedAuthViewModel
        )
    }
    
    func makeHomeView() -> HomeView {
        return HomeView(
            homeViewModel: sharedHomeViewModel,
            authViewModel: sharedAuthViewModel
        )
    }
    
    func makeBookmarkView() -> BookmarkView {
        return BookmarkView(
            bookmarkViewModel: makeBookmarkViewModel(),
            authViewModel: sharedAuthViewModel
        )
    }
    
    func makeBookmarkViewModel() -> BookmarkViewModel {
        return BookmarkViewModel(
            accountManager: sharedAccountManager,
            bookmarkManager: BookmarkManager.shared,
            userDataStoreManager: UserDataStoreManager.shared
        )
    }
    
    func makeDrawerContentView(isShowing: Binding<Bool>) -> DrawerContentView {
        return DrawerContentView(
            isShowing: isShowing,
            authViewModel: sharedAuthViewModel
        )
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
    
    func makeSettingsView(isShowing: Binding<Bool>) -> SettingsView {
        return SettingsView(
            isShowing: isShowing,
            settingsViewModel: makeSettingsViewModel()
        )
    }
    
    func makePushNotificationSettingsView(isShowing: Binding<Bool>) -> PushNotificationSettingsView {
        return PushNotificationSettingsView(
            isShowing: isShowing,
            settingsViewModel: makeSettingsViewModel()
        )
    }
    
    func makeLetterSizeSettingsView(isShowing: Binding<Bool>) -> LetterSizeSettingsView {
        return LetterSizeSettingsView(
            isShowing: isShowing,
            settingsViewModel: makeSettingsViewModel()
        )
    }
    
    func makeDarkModeSettingsView(isShowing: Binding<Bool>) -> DarkModeSettingsView {
        return DarkModeSettingsView(
            isShowing: isShowing,
            settingsViewModel: makeSettingsViewModel()
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        return sharedSettingsViewModel
    }
    
    func makeAccountSettingsView(isShowing: Binding<Bool>) -> AccountSettingsView {
        return AccountSettingsView(
            isShowing: isShowing,
            accountSettingsViewModel: makeAccountSettingsViewModel()
        )
    }
    
    func makeAccountInfoEditingView(isShowing: Binding<Bool>) -> AccountInfoEditingView {
        return AccountInfoEditingView(
            isShowing: isShowing,
            accountSettingsViewModel: makeAccountSettingsViewModel()
        )
    }
    
    func makeAccountInfoConfirmingView(isShowing: Binding<Bool>) -> AccountInfoConfirmingView {
        return AccountInfoConfirmingView(
            isShowing: isShowing,
            accountSettingsViewModel: makeAccountSettingsViewModel()
        )
    }
    
    func makeAccountInfoUpdateCompletionView(isShowing: Binding<Bool>) -> AccountInfoUpdateCompletionView {
        return AccountInfoUpdateCompletionView(
            isShowing: isShowing
        )
    }
    
    func makeWithdrawalConfirmationView(isShowing: Binding<Bool>) -> WithdrawalConfirmationView {
        return WithdrawalConfirmationView(
            isShowing: isShowing,
            accountSettingsViewModel: makeAccountSettingsViewModel()
        )
    }

    func makeAccountSettingsViewModel() -> AccountSettingsViewModel {
        return sharedAccountSettingsViewModel
    }
    
    func makeSearchView(isShowing: Binding<Bool>) -> SearchView {
        return SearchView(
            isShowing: isShowing,
            searchViewModel: makeSearchViewModel()
        )
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        return SearchViewModel(
            articleManager: sharedArticleManger,
            accountManager: sharedAccountManager,
            userDataStoreManager: UserDataStoreManager.shared,
            bookmarkManager: BookmarkManager.shared
        )
    }
    
    func makeSignInView(isShowing: Binding<Bool>) -> SignInView {
        return SignInView(
            isShowing: isShowing,
            authViewModel: sharedAuthViewModel
        )
    }
    
    func makeSignUpView(isShowing: Binding<Bool>) -> SignUpView {
        return SignUpView(
            isShowing: isShowing,
            authViewModel: sharedAuthViewModel
        )
    }

    func makeAuthViewModel() -> AuthViewModel {
        return sharedAuthViewModel
    }
    
    func makeDebugView() -> DebugView {
        return DebugView(authViewModel: sharedAuthViewModel)
    }
}
