//
//  HomeView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct HomeView: View {
    @State private var isShowingSearchView: Bool = false
    @State private var isShowingDrawer: Bool = false
    @State private var isShowingErrorAlert: Bool = false

    @ObservedObject private var homeViewModel: HomeViewModel
    @ObservedObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var appDependencyContainer: AppDependencyContainer
    
    init(homeViewModel: HomeViewModel, authViewModel: AuthViewModel) {
        self.homeViewModel = homeViewModel
        self.authViewModel = authViewModel
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(ArticleCategory.allCases, id: \.self) { category in
                                if category == homeViewModel.selectedCategory {
                                    Text(category.description)
                                        .frame(width: 150, height: 50)
                                        .background(.gray.opacity(0.3))
                                        .foregroundStyle(.black)
                                        .onTapGesture {
                                            Task {
                                                await homeViewModel.populateArticles(of: category)
                                            }
                                        }
                                } else {
                                    Text(category.description)
                                        .frame(width: 150, height: 50)
                                        .background(.gray)
                                        .foregroundStyle(.white)
                                        .onTapGesture {
                                            Task {
                                                await homeViewModel.populateArticles(of: category)
                                            }
                                        }
                                }
                            }
                            Spacer()
                                .frame(width: 5)
                        }
                    }
                    if homeViewModel.articles.isEmpty {
                        Spacer()
                        Text("該当するカテゴリの記事が存在しません。")
                        Spacer()
                    } else {
                        List {
                            ForEach(homeViewModel.articles) { article in
                                Link(destination: URL(string: article.url)!) {
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
                                        if authViewModel.signedInUser != nil {
                                            HStack {
                                                Spacer()
                                                Image(systemName: article.bookmarked ? "bookmark.fill" : "bookmark")
                                                    .onTapGesture {
                                                        Task {
                                                            await bookmarkTapped(article: article)
                                                        }
                                                    }
                                            }
                                        }
                                        
                                        Text(article.title)
                                            .font(.title2)
                                        Spacer()
                                            .frame(height: 10)
                                        Text(article.description ?? "NO DESCRIPTION")
                                            .font(.headline)
                                            .lineLimit(2)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .navigationTitle("My News")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            print("\(#file): \(#function): menu tapped")
                            isShowingDrawer = true
                        }, label: {
                            Image(systemName: "list.bullet")
                        })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            isShowingSearchView = true
                        }, label: {
                            Image(systemName: "magnifyingglass")
                        })
                    }
                }
            }
            
            DrawerView(isShowing: $isShowingDrawer)
        }
        .fullScreenCover(isPresented: $isShowingSearchView, content: {
            appDependencyContainer.makeSearchView(isShowing: $isShowingSearchView)
        })
        .task {
            await homeViewModel.populateDefaultArticles()
        }
        .refreshable {
            await homeViewModel.populateArticlesOfCurrentCategory()
        }
        .alert("Error", isPresented: $isShowingErrorAlert, actions: {
            Button(action: {
                isShowingErrorAlert = false
            }, label: {
                Text("OK")
            })
        }, message: {
            if let errorMessage = homeViewModel.errorMessage {
                Text(errorMessage)
            }
        })
        .onReceive(homeViewModel.$errorMessage, perform: { newValue in
            if newValue != nil {
                isShowingErrorAlert = true
            }
        })
        .onReceive(authViewModel.$signedInUser, perform: { user in
            if user == nil {
                isShowingDrawer = false
            }
        })
    }
    
    private func bookmarkTapped(article: Article) async {
        await homeViewModel.toggleBookmark(on: article)
    }
}

#Preview {
    let appDependencyContainer = AppDependencyContainer()
    return appDependencyContainer.makeHomeView()
}
