//
//  AccountSettingsView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct AccountSettingsView: View {
    @Binding var isShowing: Bool
    @State private var isShowingConfirmSignOutAlert: Bool = false
    @State private var isShowingSignOutCompletionAlert: Bool = false
    
    @ObservedObject private var accountSettingsViewModel: AccountSettingsViewModel
    @ObservedObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var appDependenciyContainer: AppDependencyContainer
    
    init(
        isShowing: Binding<Bool>,
        accountSettingsViewModel: AccountSettingsViewModel,
        settingsViewModel: SettingsViewModel
    ) {
        self._isShowing = isShowing
        self.accountSettingsViewModel = accountSettingsViewModel
        self.settingsViewModel = settingsViewModel
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack {
                    Color.surfacePrimary
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 48)
                        if let userAccount = accountSettingsViewModel.userAccount {
                            userNameView(proxy: proxy, info: userAccount.displayName)
                            Spacer()
                                .frame(height: 32)
                            emailView(proxy: proxy, info: userAccount.email)
                            Spacer()
                                .frame(height: 48)
                        }
                        linkToAccountEditingView(proxy: proxy)
                        Spacer()
                            .frame(height: 16)
                        signOutButton(proxy: proxy)
                        Spacer()
                        
                        linkToWithdrawalView(proxy: proxy)
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowing = false
                    }, label: {
                        Text("Dismiss")
                            .foregroundStyle(.titleNormal)
                    })
                }
            }
        }
        .alert("サインアウトしますか", isPresented: $isShowingConfirmSignOutAlert, actions: {
            Button(role: .cancel, action: {
                isShowingConfirmSignOutAlert = false
            }, label: {
                Text("キャンセル")
            })
            Button(action: {
                isShowingConfirmSignOutAlert = false
                isShowingSignOutCompletionAlert = true
            }, label: {
                Text("サインアウト")
            })
        })
        .alert("サインアウトしました", isPresented: $isShowingSignOutCompletionAlert, actions: {
            Button(action: {
                isShowingSignOutCompletionAlert = false
                isShowing = false
            }, label: {
                Text("OK")
            })
        })
        .task {
            accountSettingsViewModel.populateUserAccount()
        }
    }
}

// MARK: - View Components
private extension AccountSettingsView {
    func userNameView(proxy: GeometryProxy, info: String) -> some View {
        accountInfo(
            title: "ユーザ名",
            info: info,
            proxy: proxy
        )
    }
    
    func emailView(proxy: GeometryProxy, info: String) -> some View {
        accountInfo(
            title: "Emailアドレス",
            info: info,
            proxy: proxy
        )
    }
    
    func accountInfo(title: String, info: String, proxy: GeometryProxy) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.titleNormal)
                Text(info)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.bodyPrimary)
            }
            Spacer()
        }
        .frame(width: proxy.itemWidth)
    }
    
    func linkToAccountEditingView(proxy: GeometryProxy) -> some View {
        NavigationLink {
            appDependenciyContainer.makeAccountInfoEditingView(isShowing: $isShowing)
                .navigationBarBackButtonHidden()
        } label: {
            normalButtonLabel(title: "アカウント情報の編集", proxy: proxy)
        }
    }
    
    func signOutButton(proxy: GeometryProxy) -> some View {
        Button(action: {
            isShowingConfirmSignOutAlert = true
        }, label: {
            normalButtonLabel(title: "サインアウト", proxy: proxy)
        })
    }
    
    func linkToWithdrawalView(proxy: GeometryProxy) -> some View {
        NavigationLink {
            appDependenciyContainer.makeWithdrawalConfirmationView(isShowing: $isShowing)
                .navigationBarBackButtonHidden()
        } label: {
            normalButtonLabel(title: "アカウントを削除する", proxy: proxy)
        }
    }
    
    func normalButtonLabel(title: String, proxy: GeometryProxy) -> some View {
        Text(title)
            .frame(width: proxy.itemWidth, height: 48)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.titleNormal)
            .overlay {
                Rectangle()
                    .stroke(Color.borderNormal, lineWidth: 1)
            }
    }
}

fileprivate extension GeometryProxy {
    var itemWidth: CGFloat {
        return max(self.size.width - 32, 0)
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return NavigationStack {
        appDC.makeAccountSettingsView(isShowing: .constant(true))
    }
}
