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
    
    let dummyArticle = ["NHK", "2024-06-05", "記事のタイトル", "記事概要テキスト記事概要テキスト記事概要テキスト記事概要テキスト", "apple.logo"]
    
    @State private var isShowingSearchView: Bool = false
    
    var body: some View {
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
                    ForEach(0..<7, id: \.self) { _ in
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
                    }
                }
            }
            .navigationTitle("My News")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
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
        .fullScreenCover(isPresented: $isShowingSearchView, content: {
            SearchView()
        })
    }
}

#Preview {
    HomeView()
}
