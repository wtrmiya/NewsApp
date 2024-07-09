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
    @ObservedObject private var settingsViewModel: SettingsViewModel

    init(isShowing: Binding<Bool>, searchViewModel: SearchViewModel, settingsViewModel: SettingsViewModel) {
        self._isShowing = isShowing
        self.searchViewModel = searchViewModel
        self.settingsViewModel = settingsViewModel
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack(alignment: .top) {
                    Color.surfacePrimary
                    VStack {
                        searchFormArea(proxy: proxy)
                        Spacer()
                        searchResultArea(proxy: proxy)
                        Spacer()
                    }
                }
            }
            .navigationTitle("記事検索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.surfacePrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowing = false
                    }, label: {
                        Text("閉じる")
                            .foregroundStyle(.titleNormal)
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

// MARK: - View Components
private extension SearchView {
    func searchFormArea(proxy: GeometryProxy) -> some View {
        HStack {
            searchTextField(proxy: proxy)
            Spacer()
                .frame(width: 16)
            execSearchButton()
        }
        .padding()
    }
    
    func searchTextField(proxy: GeometryProxy) -> some View {
        let itemWidth = max(proxy.size.width - 32, 0)
        return TextField("検索文字列を入力", text: $inputText)
            .padding(8)
            .frame(maxWidth: itemWidth, minHeight: 48)
            .background(.textFieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .textInputAutocapitalization(.never)
            .font(
                .system(
                    size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                    weight: settingsViewModel.userSettings.letterWeight.thinLetterWeight
                )
            )
            .autocorrectionDisabled(true)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.border, lineWidth: 1)
            }
    }
    
    func execSearchButton() -> some View {
        Button(action: {
            Task {
                await fetchArticle()
            }
        }, label: {
            Image(systemName: "magnifyingglass")
                .frame(width: 64, height: 48)
                .font(
                    .system(
                        size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                        weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                    )
                )
                .foregroundStyle(.titleNormal)
                .background(.accent)
        })
    }
    
    @ViewBuilder
    func searchResultArea(proxy: GeometryProxy) -> some View {
        searchWord()
        searchResult(proxy: proxy)
    }
    
    @ViewBuilder
    func searchWord() -> some View {
        if !searchViewModel.searchResultWord.isEmpty {
            HStack {
                Text("検索ワード: \(searchViewModel.searchResultWord)")
                    .font(
                        .system(
                            size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                            weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                        )
                    )
                    .foregroundStyle(.bodyPrimary)
                Spacer()
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func searchResult(proxy: GeometryProxy) -> some View {
        if searchViewModel.searchResultArticles.isEmpty {
            Text("検索結果がありません")
                .font(
                    .system(
                        size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                        weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                    )
                )
        } else {
            List {
                ForEach(searchViewModel.searchResultArticles) { article in
                    ArticleView(
                        article: article,
                        isSignedIn: searchViewModel.isSignedIn,
                        bookmarkTapAction: bookmarkTapped(article:),
                        proxy: proxy,
                        userSettings: settingsViewModel.userSettings
                    )
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 24, trailing: 16))
                    .listRowBackground(Color.surfacePrimary)
                    .listRowSeparator(.hidden)
                    articleBorderView(proxy: proxy)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 0)
            .scrollDismissesKeyboard(.immediately)
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
    return appDC.makeSearchView(isShowing: .constant(true))
}
