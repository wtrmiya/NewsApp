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
    @Environment(\.displayToast) private var displayToast
    @State private var selectedTab: SelectedViewItem = .home
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        
        let appearance = UITabBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor.surfacePrimary
        UITabBar.appearance().standardAppearance = appearance
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
        .environment(\.selectedViewItem, $selectedTab)
        .onReceive(authViewModel.$signedInUser, perform: { user in
            if user != nil {
                displayToast?("サインインしました")
            } else {
                displayToast?("サインアウトしました")
            }
        })
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeContentView()
}
