//
//  ContentView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            BookmarkView()
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
