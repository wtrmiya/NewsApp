//
//  ContentView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appDependencyContainer: AppDependencyContainer
    var body: some View {
        TabView {
            appDependencyContainer.makeHomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            appDependencyContainer.makeBookmarkView()
                .tabItem {
                    Label("Bookmark", systemImage: "bookmark.fill")
                }
            #if DEBUG
            DebugView()
                .tabItem {
                    Label("Debug", systemImage: "gear")
                }
            #endif
        }
    }
}

#Preview {
    ContentView()
}
