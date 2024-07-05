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
            Color.surfacePrimary
            NavigationStack {
                VStack(spacing: 0) {
                    categoriesView
                    articleAreaView
                }
                .navigationTitle("NewsApp")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.surfacePrimary, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            isShowingDrawer = true
                        }, label: {
                            Image(systemName: "list.bullet")
                                .foregroundStyle(.titleNormal)
                        })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            isShowingSearchView = true
                        }, label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.titleNormal)
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
    }
}

// MARK: - Functions
private extension HomeView {
    func bookmarkTapped(article: Article) async {
        await homeViewModel.toggleBookmark(on: article)
    }
}

// MARK: - View Components
private extension HomeView {
    @ViewBuilder
    var categoriesView: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(ArticleCategory.allCases, id: \.self) { category in
                        categoryView(category: category)
                    }
                    Spacer()
                        .frame(width: 5)
                }
            }
            .scrollIndicators(.hidden)
            Divider()
        }
    }
    
    @ViewBuilder
    func categoryView(category: ArticleCategory) -> some View {
        let isSelected = category == homeViewModel.selectedCategory
        
        ZStack(alignment: .bottom) {
            Text(category.description)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 96, height: 48)
                .background(.surfacePrimary)
                .foregroundStyle(isSelected ? .bodyPrimary : .bodySecondary)
                .onTapGesture {
                    Task {
                        await homeViewModel.populateArticles(of: category)
                    }
                }
            if isSelected {
                Rectangle()
                    .fill(Color.accent)
                    .frame(width: 96, height: 4)
            }
        }
    }
    
    @ViewBuilder
    var articleAreaView: some View {
        if homeViewModel.articles.isEmpty {
            emptyArticlesView
        } else {
            articleListView
        }
    }
    
    @ViewBuilder
    var emptyArticlesView: some View {
        Spacer()
        Text("該当するカテゴリの記事が存在しません。")
        Spacer()
    }
    
    var articleListView: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(homeViewModel.articles) { article in
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
        if authViewModel.signedInUser != nil {
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
                    await bookmarkTapped(article: article)
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

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeHomeView()
}
