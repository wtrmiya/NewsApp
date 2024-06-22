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
    
    @ObservedObject private var bookmarkViewModel: BookmarkViewModel
    @ObservedObject private var authViewModel: AuthViewModel

    init(bookmarkViewModel: BookmarkViewModel, authViewModel: AuthViewModel) {
        self.bookmarkViewModel = bookmarkViewModel
        self.authViewModel = authViewModel
    }

    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    List {
                        ForEach(bookmarkViewModel.articles.indices, id: \.self) { index in
                            let article = bookmarkViewModel.articles[index]
                            Link(destination: URL(string: article.url)!, label: {
                                VStack {
                                    HStack {
                                        Text(article.source.name)
                                        Spacer()
                                        Text(article.publishedAt)
                                    }
                                    if let imageUrl = article.urlToImage {
                                        AsyncImage(url: URL(string: imageUrl)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 300, height: 200)
                                        } placeholder: {
                                            Image(systemName: "photo.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 300, height: 200)
                                        }
                                    } else {
                                        Image(systemName: "photo.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 300, height: 200)
                                    }
                                    
                                    Text(article.title)
                                        .font(.title2)
                                    Spacer()
                                        .frame(height: 10)
                                    Text(article.description ?? "NO DESCRIPTION")
                                        .font(.headline)
                                        .lineLimit(2)
                                }
                            })
                        }
                        .onDelete(perform: { indexSet in
                            Task {
                                await deleteBookmarks(indexSet: indexSet)
                            }
                        })
                    }
                    .listStyle(.plain)
                }
                .navigationTitle("Bookmark")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            isShowingDrawer = true
                        }, label: {
                            Image(systemName: "list.bullet")
                        })
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        EditButton()
                    }
                }
            }
            
            DrawerView(isShowing: $isShowingDrawer)

            if authViewModel.signedInUser == nil {
                ZStack {
                    Color.gray.opacity(0.7)
                    
                    SuggestSignInView()
                }
            }
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
    
    private func deleteBookmarks(indexSet: IndexSet) async {
        await bookmarkViewModel.deleteBookmarks(indexSet: indexSet)
    }
}

#Preview {
    let appDependencyContainer = AppDependencyContainer()
    return appDependencyContainer.makeBookmarkView()
}

struct SuggestSignInView: View {
    @State private var isShowingSignInView: Bool = false
    @State private var isShowingSignUpView: Bool = false
    @EnvironmentObject private var appDependencyContainer: AppDependencyContainer
    
    var body: some View {
        VStack {
            Text("該当の機能はサインイン後に使用可能です")
            Spacer()
                .frame(height: 20)
            Button(action: {
                isShowingSignInView = true
            }, label: {
                Text("サインイン")
            })
            Spacer()
                .frame(height: 20)
            Button(action: {
                isShowingSignUpView = true
            }, label: {
                Text("サインアップ")
            })
        }
        .background(.white)
        .fullScreenCover(isPresented: $isShowingSignUpView) {
            appDependencyContainer.makeSignUpView(isShowing: $isShowingSignUpView)
        }
        .fullScreenCover(isPresented: $isShowingSignInView) {
            appDependencyContainer.makeSignInView(isShowing: $isShowingSignInView)
        }
    }
}
