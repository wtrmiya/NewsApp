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
    
    init(bookmarkViewModel: BookmarkViewModel) {
        self.bookmarkViewModel = bookmarkViewModel
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

            if !bookmarkViewModel.isSignedIn {
                ZStack {
                    Color.gray.opacity(0.7)
                    
                    SuggestSignInView()
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingSearchView, content: {
            SearchView(isShowing: $isShowingSearchView)
        })
        .task {
            await bookmarkViewModel.populateBookmarkedArticles()
        }
    }
}

#Preview {
    let appDependencyContainer = AppDependencyContainer()
    return appDependencyContainer.makeBookmarkView()
}

struct SuggestSignInView: View {
    var body: some View {
        VStack {
            Text("該当の機能はサインイン後に使用可能です")
            Spacer()
                .frame(height: 20)
            Button(action: {
                print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
            }, label: {
                Text("サインイン")
            })
            Spacer()
                .frame(height: 20)
            Button(action: {
                print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
            }, label: {
                Text("新規登録")
            })
        }
        .background(.white)
    }
}
