//
//  AppDependencyContainer.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation

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
        HomeView(homeViewModel: makeHomeViewModel())
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            articleManager: ArticleManager.shared,
            bookmarkManager: BookmarkManager.shared,
            accountManager: sharedAccountManager
        )
    }
}
