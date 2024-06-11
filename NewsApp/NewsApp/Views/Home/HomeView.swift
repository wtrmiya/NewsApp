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
    
    @StateObject private var homeViewModel: HomeViewModel = HomeViewModel()
    
    @State private var isShowingErrorAlert: Bool = false
    
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
                        ForEach(homeViewModel.articles, id: \.self) { article in
                            Link(destination: URL(string: article.url)!) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(article.source.name)
                                        Text(article.title)
                                        Text(article.description ?? "no description")
                                    }
                                    VStack {
                                        Text(article.publishedAt)
//                                        AsyncImage(url: URL(string: article.urlToImage))
                                        Image(systemName: "apple.logo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100, height: 100)
                                        Image(systemName: "bookmark.fill")
                                    }
                                }
                            }
                        }
                    }
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
}

#Preview {
    HomeView()
}
