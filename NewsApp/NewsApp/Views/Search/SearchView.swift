//
//  SearchView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct SearchView: View {
    @State private var inputText: String = ""
    @Binding var isShowing: Bool
    
    @EnvironmentObject private var appDependencyContainer: AppDependencyContainer
    @ObservedObject private var searchViewModel: SearchViewModel
    
    init(isShowing: Binding<Bool>, searchViewModel: SearchViewModel) {
        self._isShowing = isShowing
        self.searchViewModel = searchViewModel
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("検索文字列を入力", text: $inputText)
                        .padding(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(height: 44)
                        }
                    Spacer()
                        .frame(width: 16)
                    Button(action: {
                        Task {
                            await fetchArticle()
                        }
                    }, label: {
                        Image(systemName: "magnifyingglass")
                            .frame(width: 70, height: 44)
                            .foregroundStyle(.white)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    })
                }
                .padding()
                if !searchViewModel.searchResultWord.isEmpty {
                    HStack {
                        Text("検索ワード: \(searchViewModel.searchResultWord)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                }
                if searchViewModel.searchResultArticles.isEmpty {
                    Spacer()
                    Text("検索結果がありません")
                    Spacer()
                } else {
                    List {
                        ForEach(searchViewModel.searchResultArticles) { article in
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
                                    if searchViewModel.isSignedIn {
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
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .navigationTitle("記事検索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowing = false
                    }, label: {
                        Text("閉じる")
                    })
                }
            }
        }
    }
    
    private func fetchArticle() async {
        await searchViewModel.fetchArticle(searchText: inputText)
        inputText = ""
    }
    
    private func bookmarkTapped(article: Article) async {
        await searchViewModel.toggleBookmark(on: article)
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeSearchView(isShowing: .constant(true))
}
