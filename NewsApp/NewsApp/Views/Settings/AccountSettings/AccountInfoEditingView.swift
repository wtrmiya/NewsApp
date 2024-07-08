//
//  AccountInfoEditingView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/10.
//

import SwiftUI

struct AccountInfoEditingView: View {
    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var repeatedPassword: String = ""
    
    @Binding var isShowing: Bool
    @ObservedObject private var accountSettingsViewModel: AccountSettingsViewModel
    
    @EnvironmentObject private var appDependencyContainer: AppDependencyContainer
    
    init(isShowing: Binding<Bool>, accountSettingsViewModel: AccountSettingsViewModel) {
        self._isShowing = isShowing
        self.accountSettingsViewModel = accountSettingsViewModel
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
                        
                        VStack {
                            userNameForm(proxy: proxy)
                            Spacer()
                                .frame(height: 32)
                            emailAddressForm(proxy: proxy)
                            Spacer()
                                .frame(height: 32)
                            passwordForm(proxy: proxy)
                        }
                        
                        Spacer()
                        linkToConfirmationView(proxy: proxy)
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
    }
}

private extension AccountInfoEditingView {
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
    
    func userNameForm(proxy: GeometryProxy) -> some View {
        textForm(
            title: "変更後のユーザ名",
            placeholder: "ユーザ名を入力してください",
            textBinding: $accountSettingsViewModel.inputDisplayName,
            proxy: proxy
        )
    }

    func emailAddressForm(proxy: GeometryProxy) -> some View {
        textForm(
            title: "変更後のEmailアドレス",
            placeholder: "Emailアドレスを入力してください",
            textBinding: $accountSettingsViewModel.inputEmail,
            proxy: proxy
        )
    }
    
    func passwordForm(proxy: GeometryProxy) -> some View {
        textForm(
            title: "パスワード",
            placeholder: "パスワードを入力してください",
            textBinding: $accountSettingsViewModel.inputPassword,
            proxy: proxy
        )
    }
    
    func textForm(title: String, placeholder: String, textBinding: Binding<String>, proxy: GeometryProxy) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
            TextField(placeholder, text: textBinding)
                .standardTextFieldModifier(width: proxy.itemWidth)
        }
    }
    
    func linkToConfirmationView(proxy: GeometryProxy) -> some View {
        NavigationLink {
            appDependencyContainer.makeAccountInfoConfirmingView(isShowing: $isShowing)
        } label: {
            Text("変更内容の確認")
                .frame(width: proxy.itemWidth, height: 48)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.titleNormal)
                .overlay {
                    Rectangle()
                        .stroke(Color.borderNormal, lineWidth: 1)
                }
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
        appDC.makeAccountInfoEditingView(isShowing: .constant(true))
    }
}
