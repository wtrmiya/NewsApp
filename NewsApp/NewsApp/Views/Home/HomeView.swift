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
            articleListView()
        }
    }
    
    @ViewBuilder
    var emptyArticlesView: some View {
        Spacer()
        Text("該当するカテゴリの記事が存在しません。")
        Spacer()
    }
    
    func articleListView() -> some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(homeViewModel.articles) { article in
                        ArticleView(
                            article: article,
                            isSignedIn: authViewModel.signedInUser != nil,
                            bookmarkTapAction: bookmarkTapped(article:),
                            proxy: proxy
                        )
                            .padding(EdgeInsets(top: 16, leading: 16, bottom: 24, trailing: 16))
                        articleBorderView(proxy: proxy)
                    }
                }
            }
            .background(.surfacePrimary)
        }
    }
    
    private func articleBorderView(proxy: GeometryProxy) -> some View {
        Rectangle()
            .fill(Color.thickLine)
            .frame(width: proxy.size.width, height: 8)
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeHomeView()
}
