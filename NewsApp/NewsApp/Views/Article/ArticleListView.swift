//
//  ArticleListView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/07/06.
//

import SwiftUI

struct ArticleListView: View {
    private var articles: [Article]
    private var signedInUser: UserAccount?
    private var bookmarkTapAction: (Article) async -> Void
    
    init(articles: [Article], signedInUser: UserAccount? = nil, bookmarkTapAction: @escaping (Article) async -> Void) {
        self.articles = articles
        self.signedInUser = signedInUser
        self.bookmarkTapAction = bookmarkTapAction
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(articles) { article in
                        articleView(article: article, proxy: proxy)
                            .padding(EdgeInsets(top: 16, leading: 16, bottom: 24, trailing: 16))
                        articleBorderView(proxy: proxy)
                    }
                }
            }
            .background(.surfacePrimary)
        }
    }
    
    func articleView(article: Article, proxy: GeometryProxy) -> some View {
        Link(destination: URL(string: article.url)!) {
            VStack(spacing: 16) {
                HStack {
                    articleSourceView(article: article)
                    Spacer()
                    publishedDateView(article: article)
                    bookmarkView(article: article)
                }
                articleImageView(article: article, proxy: proxy)
                articleBodyView(article: article)
            }
        }
    }
    
    func articleSourceView(article: Article) -> some View {
        Text(article.source.name)
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(.bodyPrimary)
    }
    
    func publishedDateView(article: Article) -> some View {
        return Text(article.publishedAt.localDateString)
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(.bodyPrimary)
    }
    
    @ViewBuilder
    func bookmarkView(article: Article) -> some View {
        if signedInUser != nil {
            ZStack {
                Circle()
                    .stroke(Color.thinLine, lineWidth: 1)
                    .frame(width: 32, height: 32)
                Image(systemName: article.bookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.bodySecondary)
            }
            .onTapGesture {
                Task {
                    await bookmarkTapAction(article)
                }
            }
        }
    }

    @ViewBuilder
    func articleImageView(article: Article, proxy: GeometryProxy) -> some View {
        if let imageUrl = article.urlToImage {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .articleImageModifier(proxy: proxy)
            } placeholder: {
                placeholderImage(proxy: proxy)
            }
        } else {
            placeholderImage(proxy: proxy)
        }
    }
    
    func placeholderImage(proxy: GeometryProxy) -> some View {
        Image(systemName: "photo.fill")
            .articleImageModifier(proxy: proxy)
    }
    
    @ViewBuilder
    func articleBodyView(article: Article) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.thinLine, lineWidth: 1)
            VStack {
                Text(article.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.bodyPrimary)
                    .lineSpacing(4)
                    .multilineTextAlignment(.leading)
                Spacer()
                    .frame(height: 10)
                Text(article.description ?? "NO DESCRIPTION")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.bodyPrimary)
                    .lineLimit(2)
                    .lineSpacing(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
        }
    }
    
    private func articleBorderView(proxy: GeometryProxy) -> some View {
        Rectangle()
            .fill(Color.thickLine)
            .frame(width: proxy.size.width, height: 8)
    }
}

fileprivate extension Image {
    func articleImageModifier(proxy: GeometryProxy) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: proxy.size.width - 32, height: 200)
            .clipped()
    }
}

fileprivate extension String {
    var localDateString: String {
        // 基本的に末尾にZが付いているのでUTC
        // ローカルのタイムゾーンを指定して適切な日付文字列に変換する
        let iso8601DateFormatter = ISO8601DateFormatter()
        guard let utcDate = iso8601DateFormatter.date(from: self)
        else {
            return self
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Locale.preferredLanguages.first!)
        dateFormatter.dateFormat = "yyyy/MM/dd a hh:mm"
        return dateFormatter.string(from: utcDate)
    }
}
