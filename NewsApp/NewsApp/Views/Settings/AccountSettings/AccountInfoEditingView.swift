//
//  AccountInfoEditingView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/10.
//

import SwiftUI

struct AccountInfoEditingView: View {
    @State private var isShowingDiscardingInputAlert: Bool = false
    @State private var isShowingNotChangingAlert: Bool = false
    @Binding private var navigationPath: [String]

    @Binding var isShowing: Bool
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
                ScrollView {
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
                            .frame(height: 48)
                        linkToConfirmationView(proxy: proxy)
                        Spacer()
                            .frame(height: 16)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationTitle("アカウントの設定")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.surfacePrimary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
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
        .alert("既存の内容と変更がありません\n設定画面を閉じますか", isPresented: $isShowingNotChangingAlert) {
            Button(role: .cancel, action: {
                isShowingNotChangingAlert = false
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
                    .font(
                        .system(
                            size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                            weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                        )
                    )
                    .foregroundStyle(.titleNormal)
                Text(info)
                    .font(
                        .system(
                            size: settingsViewModel.userSettings.letterSize.accountInfoLetterSize,
                            weight: settingsViewModel.userSettings.letterWeight.thinLetterWeight
                        )
                    )
                    .foregroundStyle(.bodyPrimary)
            }
            Spacer()
        }
        .frame(width: proxy.itemWidth)
    }
    
    @ViewBuilder
    func userNameForm(proxy: GeometryProxy) -> some View {
        textForm(
            title: "変更後のユーザ名",
            placeholder: "ユーザ名を入力してください",
            textBinding: $accountSettingsViewModel.inputDisplayName,
            proxy: proxy,
            errorMessage: "英数字3文字以上を入力してください",
            validationResult: accountSettingsViewModel.inputDisplayNameValid
        )
    }

    @ViewBuilder
    func emailAddressForm(proxy: GeometryProxy) -> some View {
        textForm(
            title: "変更後のEmailアドレス",
            placeholder: "Emailアドレスを入力してください",
            textBinding: $accountSettingsViewModel.inputEmail,
            proxy: proxy,
            errorMessage: "Emailの形式が誤っています",
            validationResult: accountSettingsViewModel.inputEmailValid
        )
    }
    
    @ViewBuilder
    func passwordForm(proxy: GeometryProxy) -> some View {
        textForm(
            title: "使用中のパスワード",
            placeholder: "パスワードを入力してください",
            textBinding: $accountSettingsViewModel.inputPassword,
            proxy: proxy,
            errorMessage: "Emailアドレス変更時、パスワードは必須です",
            validationResult: accountSettingsViewModel.inputPasswordValid
        )
        .disabled(!accountSettingsViewModel.isEditingEmail)
    }

    @ViewBuilder
    // swiftlint:disable:next function_parameter_count line_length
    func textForm( title: String, placeholder: String, textBinding: Binding<String>, proxy: GeometryProxy, errorMessage: String, validationResult: Bool ) -> some View {
    // swiftlint:disable:previous function_parameter_count line_length
        VStack(alignment: .leading) {
            Text(title)
                .font(
                    .system(
                        size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                        weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                    )
                )
            TextField(placeholder, text: textBinding)
                .standardTextFieldModifier(width: proxy.itemWidth)
            if !validationResult {
                Text(errorMessage)
                    .font(
                        .system(
                            size: settingsViewModel.userSettings.letterSize.captionLetterSize,
                            weight: settingsViewModel.userSettings.letterWeight.thinLetterWeight
                        )
                    )
                    .foregroundStyle(.destructive)
            } else {
                EmptyView()
            }
        }
    }
    
    func linkToConfirmationView(proxy: GeometryProxy) -> some View {
        Button {
            if accountSettingsViewModel.didValuesChanged {
                navigationPath.append(AppDependencyContainer.accountInfoConfirmingViewName)
            } else {
                isShowingNotChangingAlert = true
            }
        } label: {
            Text("変更内容の確認")
                .frame(width: proxy.itemWidth, height: 48)
                .font(
                    .system(
                        size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                        weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                    )
                )
                .foregroundStyle(.titleNormal)
                .overlay {
                    Rectangle()
                        .stroke(Color.borderNormal, lineWidth: 1)
                }
        }
        .disabled(!accountSettingsViewModel.inputInfoValid)
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
        appDC.makeAccountInfoEditingView(isShowing: .constant(true), navigationPath: .constant([]))
    }
}
