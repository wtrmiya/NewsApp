//
//  AccountInfoConfirmingView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/10.
//

import SwiftUI

struct AccountInfoConfirmingView: View {
    @Binding var isShowing: Bool
    @Binding var navigationPath: [String]
    @State private var isShowingDiscardingInputAlert: Bool = false
    @ObservedObject private var accountSettingsViewModel: AccountSettingsViewModel
    @ObservedObject private var settingsViewModel: SettingsViewModel

    @EnvironmentObject private var appDependencyContainer: AppDependencyContainer
    
    init(
        isShowing: Binding<Bool>,
        navigationPath: Binding<[String]>,
        accountSettingsViewModel: AccountSettingsViewModel,
        settingsViewModel: SettingsViewModel
    ) {
        self._isShowing = isShowing
        self._navigationPath = navigationPath
        self.accountSettingsViewModel = accountSettingsViewModel
        self.settingsViewModel = settingsViewModel
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.surfacePrimary
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 48)
                    userNameView(proxy: proxy)
                    Spacer()
                        .frame(height: 32)
                    emailView(proxy: proxy)
                    Spacer()
                    confirmButton(proxy: proxy)
                    Spacer()
                        .frame(height: 16)
                }
            }
        }
        .navigationTitle("アカウントの設定")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.surfacePrimary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    navigationPath.removeLast()
                }, label: {
                    Text("< 内容入力")
                        .foregroundStyle(.titleNormal)
                })
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isShowingDiscardingInputAlert = true
                }, label: {
                    Text("閉じる")
                        .foregroundStyle(.titleNormal)
                })
            }
        }
        .alert("入力内容は失われます\n設定画面を閉じますか", isPresented: $isShowingDiscardingInputAlert) {
            Button(role: .cancel, action: {
                isShowingDiscardingInputAlert = false
            }, label: {
                Text("キャンセル")
            })
            Button(action: {
                accountSettingsViewModel.resetInputValuesToDefault()
                isShowing = false
                navigationPath.removeAll()
            }, label: {
                Text("OK")
            })
        }
    }
}

// MARK: - View Components
private extension AccountInfoConfirmingView {
    @ViewBuilder
    func userNameView(proxy: GeometryProxy) -> some View {
        if let displayName = accountSettingsViewModel.userAccount?.displayName {
            accountInfo(
                title: "ユーザ名",
                currentValue: displayName,
                newValue: accountSettingsViewModel.inputDisplayName,
                proxy: proxy
            )
        }
    }
    
    @ViewBuilder
    func emailView(proxy: GeometryProxy) -> some View {
        if let email = accountSettingsViewModel.userAccount?.email {
            accountInfo(
                title: "Emailアドレス",
                currentValue: email,
                newValue: accountSettingsViewModel.inputEmail,
                proxy: proxy
            )
        }
    }
    
    func accountInfo(title: String, currentValue: String, newValue: String, proxy: GeometryProxy) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(
                        .system(
                            size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                            weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                        )
                    )
                    .foregroundStyle(.titleNormal)
                accountInfo(value: currentValue)
                Spacer()
                    .frame(height: 8)
                Image(systemName: "arrow.down")
                    .font(
                        .system(
                            size: settingsViewModel.userSettings.letterSize.accountInfoLetterSize,
                            weight: settingsViewModel.userSettings.letterWeight.thinLetterWeight
                        )
                    )
                    .foregroundStyle(.bodyPrimary)
                Spacer()
                    .frame(height: 8)
                if currentValue == newValue {
                    accountInfo(value: "(変更なし)")
                } else {
                    accountInfo(value: newValue)
                }
            }
            Spacer()
        }
        .frame(width: proxy.itemWidth)
    }
    
    func confirmButton(proxy: GeometryProxy) -> some View {
        Button(action: {
            accountSettingsViewModel.updateAccountInfo()
            isShowing = false
        }, label: {
            Text("変更を確定する")
                .frame(width: proxy.itemWidth, height: 48)
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
    
    func accountInfo(value: String) -> some View {
        Text(value)
            .font(
                .system(
                    size: settingsViewModel.userSettings.letterSize.accountInfoLetterSize,
                    weight: settingsViewModel.userSettings.letterWeight.thinLetterWeight
                )
            )
            .foregroundStyle(.bodyPrimary)
    }
}

fileprivate extension GeometryProxy {
    var itemWidth: CGFloat {
        return max(self.size.width - 32, 0)
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    NavigationStack {
        appDC.makeAccountInfoConfirmingView(
            isShowing: .constant(true),
            navigationPath: .constant([])
        )
    }
}
