//
//  BookmarkView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct BookmarkView: View {
    @State private var isShowingAlert: Bool = false
    @State private var isShowingSearchView: Bool = false
    @State private var isShowingDrawer: Bool = false
    @State private var isEditing: Bool = false
    
    @ObservedObject private var bookmarkViewModel: BookmarkViewModel
    @ObservedObject private var authViewModel: AuthViewModel
    @ObservedObject private var settingsViewModel: SettingsViewModel

    init(bookmarkViewModel: BookmarkViewModel, authViewModel: AuthViewModel, settingsViewModel: SettingsViewModel) {
        self.bookmarkViewModel = bookmarkViewModel
        self.authViewModel = authViewModel
        self.settingsViewModel = settingsViewModel
    }

    var body: some View {
        ZStack {
            bookmarkView
            DrawerView(isShowing: $isShowingDrawer)
            suggestSignInView
        }
        .task {
            await bookmarkViewModel.populateBookmarkedArticles()
        }
        .onReceive(authViewModel.$signedInUser, perform: { user in
            if user == nil {
                isShowingDrawer = false
            }
        })
    }
}

// MARK: - Functions
private extension BookmarkView {
    private func deleteBookmarks(indexSet: IndexSet) async {
        await bookmarkViewModel.deleteBookmarks(indexSet: indexSet)
    }
}

// MARK: - View Components
private extension BookmarkView {
    var bookmarkView: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack {
                    Color.surfacePrimary
                    if bookmarkViewModel.articles.isEmpty {
                        VStack {
                            Text("ブックマークした記事がありません。")
                                .font(
                                    .system(
                                        size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                                        weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                                    )
                                )
                                .foregroundStyle(.bodyPrimary)
                        }
                    } else {
                        List {
                            ForEach(bookmarkViewModel.articles.indices, id: \.self) { index in
                                let article = bookmarkViewModel.articles[index]
                                ArticleView(
                                    article: article,
                                    isSignedIn: authViewModel.signedInUser != nil,
                                    bookmarkTapAction: nil,
                                    proxy: proxy,
                                    userSettings: settingsViewModel.userSettings
                                )
                                .padding(EdgeInsets(top: 16, leading: 16, bottom: 24, trailing: 16))
                                .listRowBackground(Color.surfacePrimary)
                                .listRowSeparator(.hidden)
                                articleBorderView(proxy: proxy)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .listRowSeparator(.hidden)
                            }
                            .onDelete(perform: { indexSet in
                                Task {
                                    await deleteBookmarks(indexSet: indexSet)
                                }
                            })
                        }
                        .listStyle(.plain)
                        .environment(\.defaultMinListRowHeight, 0)
                    }
                }
                .navigationTitle("ブックマーク")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.surfacePrimary, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            isShowingDrawer = true
                        }, label: {
                            Image(systemName: "list.bullet")
                                .foregroundStyle(.titleNormal)
                        })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                            .foregroundStyle(.titleNormal)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var suggestSignInView: some View {
        if authViewModel.signedInUser == nil {
            ZStack {
                Color.gray.opacity(0.7)
                
                SuggestSignInView(settingsViewModel: settingsViewModel)
            }
        }
    }
    
    private func articleBorderView(proxy: GeometryProxy) -> some View {
        Rectangle()
            .fill(Color.thickLine)
            .frame(width: proxy.size.width, height: 8)
    }
}

struct SuggestSignInView: View {
    @State private var isShowingSignInView: Bool = false
    @State private var isShowingSignUpView: Bool = false
    @EnvironmentObject private var appDependencyContainer: AppDependencyContainer
    @ObservedObject private var settingsViewModel: SettingsViewModel
    
    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("該当の機能はサインイン後に使用可能です")
                .frame(width: 184)
                .font(
                    .system(
                        size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                        weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                    )
                )
                .multilineTextAlignment(.leading)
                .foregroundStyle(.bodyPrimary)
            Spacer()
                .frame(height: 24)
            Button(action: {
                isShowingSignUpView = true
            }, label: {
                Text("サインアップ")
                    .font(
                        .system(
                            size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                            weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                        )
                    )
                    .frame(width: 184, height: 48)
                    .background(.accent)
                    .foregroundStyle(.titleNormal)
            })
            Spacer()
                .frame(height: 16)
            Button(action: {
                isShowingSignInView = true
            }, label: {
                Text("サインイン")
                    .font(
                        .system(
                            size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                            weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                        )
                    )
                    .frame(width: 184, height: 48)
                    .background(.surfacePrimary)
                    .foregroundStyle(.titleNormal)
                    .overlay {
                        Rectangle()
                            .stroke(Color.borderNormal, lineWidth: 1)
                            .frame(width: 184, height: 48)
                    }
            })
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(.surfacePrimary)
        .fullScreenCover(isPresented: $isShowingSignUpView) {
            appDependencyContainer.makeSignUpView(isShowing: $isShowingSignUpView)
        }
        .fullScreenCover(isPresented: $isShowingSignInView) {
            appDependencyContainer.makeSignInView(isShowing: $isShowingSignInView)
        }
    }
}

#Preview {
    let appDependencyContainer = AppDependencyContainer()
    return appDependencyContainer.makeBookmarkView()
}
