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
        self.sharedAccountManager = makeAccountManager()
        self.sharedUserSettingsManager = UserSettingsManager.shared
        
        func makeAccountManager() -> AccountProtocol {
            return AccountManager.shared
        }
        
        func makeUserSettingsManager() -> UserSettingsManagerProtocol {
            return UserSettingsManager.shared
        }
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
}
