//
//  AccountInfoConfirmingView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/10.
//

import SwiftUI

struct AccountInfoConfirmingView: View {
    @Binding var isShowing: Bool
    @ObservedObject private var accountSettingsViewModel: AccountSettingsViewModel
    @ObservedObject private var settingsViewModel: SettingsViewModel

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appDependencyContainer: AppDependencyContainer
    
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
                    dismiss()
                }, label: {
                    Text("< 内容入力")
                        .foregroundStyle(.titleNormal)
                })
            }
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
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.titleNormal)
                Text(currentValue)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.bodyPrimary)
                Spacer()
                    .frame(height: 8)
                Image(systemName: "arrow.down")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.bodyPrimary)
                Spacer()
                    .frame(height: 8)
                if currentValue == newValue {
                    Text("(変更なし)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.bodyPrimary)
                } else {
                    Text(newValue)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.bodyPrimary)
                }
            }
            Spacer()
        }
        .frame(width: proxy.itemWidth)
    }
    
    func confirmButton(proxy: GeometryProxy) -> some View {
        Button(action: {
            print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
            isShowing = false
        }, label: {
            Text("変更を確定する")
                .frame(width: proxy.itemWidth, height: 48)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.titleNormal)
                .background(.accent)
        })
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
        appDC.makeAccountInfoConfirmingView(isShowing: .constant(true))
    }
}
