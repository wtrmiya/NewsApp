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
    
    let dummyArticle = ["NHK", "2024-06-05", "記事のタイトル", "記事概要テキスト記事概要テキスト記事概要テキスト記事概要テキスト", "apple.logo"]

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Input word", text: $inputText)
                    .padding()
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
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowing = false
                    }, label: {
                        Text("Cancel")
                    })
                }
            }
        }
    }
}

#Preview {
    SearchView(isShowing: .constant(true))
}
