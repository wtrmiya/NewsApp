//
//  ArticleView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/07/06.
//

import SwiftUI

struct ArticleView: View {
    private var article: Article
    private var isSignedIn: Bool
    private var bookmarkTapAction: ((Article) async -> Void)?
    private var proxy: GeometryProxy
    private var userSettings: UserSettings

    @Environment(\.selectedViewItem) private var selectedViewItem: Binding<SelectedViewItem>?
    var currentViewItem: SelectedViewItem {
        if let currentViewItem = selectedViewItem?.wrappedValue {
            return currentViewItem
        } else {
            return .home
        }
    }
    
    init(article: Article,
         isSignedIn: Bool,
         bookmarkTapAction: ((Article) async -> Void)?,
         proxy: GeometryProxy,
         userSettings: UserSettings
    ) {
        self.article = article
        self.isSignedIn = isSignedIn
        self.bookmarkTapAction = bookmarkTapAction
        self.proxy = proxy
        self.userSettings = userSettings
    }
    
    var body: some View {
        Link(destination: URL(string: article.url)!) {
            VStack(spacing: 16) {
                HStack {
                    articleSourceView(article: article)
                    Spacer()
                    publishedDateView(article: article)
                    if currentViewItem == .home {
                        bookmarkView(article: article)
                    }
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
        if isSignedIn {
            ZStack {
                Circle()
                    .stroke(Color.thinLine, lineWidth: 1)
                    .frame(width: 32, height: 32)
                Image(systemName: article.bookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.bodySecondary)
            }
            .onTapGesture {
                if let bookmarkTapAction {
                    Task {
                        await bookmarkTapAction(article)
                    }
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
