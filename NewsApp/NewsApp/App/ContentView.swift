//
//  ContentView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appDependencyContainer: AppDependencyContainer
    @ObservedObject private var authViewModel: AuthViewModel
    @ObservedObject private var settingsViewModel: SettingsViewModel
    @ObservedObject private var appStateViewModel: AppStateViewModel
    @Environment(\.displayToast) private var displayToast
    @State private var selectedTab: SelectedViewItem = .home
    
    init(authViewModel: AuthViewModel, settingsViewModel: SettingsViewModel, appStateViewModel: AppStateViewModel) {
        self.authViewModel = authViewModel
        self.settingsViewModel = settingsViewModel
        self.appStateViewModel = appStateViewModel
        
        let appearance = UITabBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor.surfacePrimary
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            appDependencyContainer.makeHomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(SelectedViewItem.home)
            appDependencyContainer.makeBookmarkView()
                .tabItem {
                    Label("Bookmark", systemImage: "bookmark.fill")
                }
                .tag(SelectedViewItem.bookmark)
            #if DEBUG
            appDependencyContainer.makeDebugView()
                .tabItem {
                    Label("Debug", systemImage: "gear")
                }
            #endif
        }
        .preferredColorScheme(settingsViewModel.userSettings.darkMode.colorScheme)
        .tint(.accent)
        .environment(\.selectedViewItem, $selectedTab)
        .onReceive(appStateViewModel.$appState, perform: { appState in
            if let appState {
                if appState == .launchedSignedIn {
                    displayToast?("サインインしました")
                } else if appState == .launchedSignedOut {
                    displayToast?("サインアウトしました")
                }
            }
        })
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeContentView()
}
