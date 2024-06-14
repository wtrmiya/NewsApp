//
//  HomeView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct HomeView: View {
    let categories = [
        "トップ",
        "ビジネス",
        "テクノロジ",
        "エンタメ",
        "スポーツ",
        "健康",
        "科学"
    ]
    
    let dummyArticle = [
        "NHK",
        "2024-06-05",
        "記事のタイトル",
        "記事概要テキスト記事概要テキスト記事概要テキスト記事概要テキスト",
        "apple.logo",
        "https://apple.com"
    ]
    
    @State private var isShowingSearchView: Bool = false
    @State private var isShowingDrawer: Bool = false
    @State private var isShowingErrorAlert: Bool = false

    @ObservedObject private var homeViewModel: HomeViewModel
    
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(categories, id: \.self) { category in
                                Text(category)
                                    .frame(width: 150, height: 50)
                                    .background(.gray)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                                .frame(width: 5)
                        }
                    }
                    List {
                        ForEach(homeViewModel.articles.indices, id: \.self) { index in
                            let article = homeViewModel.articles[index]
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
                                    HStack {
                                        Spacer()
                                        Image(systemName: article.bookmarked ? "bookmark.fill" : "bookmark")
                                            .onTapGesture {
                                                Task {
                                                    await bookmarkTapped(articleIndex: index)
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
                .navigationTitle("My News")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
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
            SearchView(isShowing: $isShowingSearchView)
        })
        .task {
            await homeViewModel.populateArticles()
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
    }
    
    private func bookmarkTapped(articleIndex: Int) async {
        await homeViewModel.toggleBookmark(articleIndex: articleIndex)
    }
}

#Preview {
    let appDependencyContainer = AppDependencyContainer()
    return appDependencyContainer.makeHomeView()
}
