//
//  BookmarkView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct BookmarkView: View {
    private let bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()
    @State private var isShowingAlert: Bool = false
    @State private var isShowingSearchView: Bool = false
    @State private var isShowingDrawer: Bool = false

    let dummyArticle = [
        "NHK",
        "2024-06-05",
        "記事のタイトル",
        "記事概要テキスト記事概要テキスト記事概要テキスト記事概要テキスト",
        "apple.logo",
        "https://apple.com"
    ]
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    List {
                        ForEach(0..<7, id: \.self) { _ in
                            Link(destination: URL(string: dummyArticle[5])!, label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(dummyArticle[0])
                                        Text(dummyArticle[2])
                                        Text(dummyArticle[3])
                                    }
                                    VStack {
                                        Text(dummyArticle[0])
                                        Image(systemName: dummyArticle[4])
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 60, height: 60)
                                        Image(systemName: "bookmark.fill")
                                    }
                                }
                            })
                        }
                    }
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
                        Button(action: {
                            isShowingSearchView = true
                        }, label: {
                            Image(systemName: "magnifyingglass")
                        })
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
    }
}

#Preview {
    BookmarkView()
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
