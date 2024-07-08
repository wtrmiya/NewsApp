//
//  WithdrawalConfirmationView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct WithdrawalConfirmationView: View {
    @Binding var isShowing: Bool
    @State private var isShowingWithdrawalCompletionAlert: Bool = false
    
    @ObservedObject private var accountSettingsViewModel: AccountSettingsViewModel
    @EnvironmentObject private var appDependenciyContainer: AppDependencyContainer
    @Environment(\.dismiss) private var dismiss

    init(isShowing: Binding<Bool>, accountSettingsViewModel: AccountSettingsViewModel) {
        self._isShowing = isShowing
        self.accountSettingsViewModel = accountSettingsViewModel
    }

    var body: some View {
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

                    Spacer()
                    
                    Button(action: {
                        isShowing = false
                    }, label: {
                        Text("このまま使用を続ける")
                            .frame(width: proxy.itemWidth, height: 48)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.titleNormal)
                            .overlay {
                                Rectangle()
                                    .stroke(Color.borderNormal, lineWidth: 1)
                            }
                    })
                    Spacer()
                        .frame(height: 16)
                    Button(action: {
                        isShowingWithdrawalCompletionAlert = true
                    }, label: {
                        Text("アカウントを削除する")
                            .frame(width: proxy.itemWidth, height: 48)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.titleDestructive)
                            .background(.destructive)
                    })
                    Spacer()
                        .frame(height: 16)
                }
            }
        }
        .alert("退会しました。\nご利用ありがとうございました。", isPresented: $isShowingWithdrawalCompletionAlert, actions: {
            Button(action: {
                isShowing = false
            }, label: {
                Text("ホームへ")
            })
        })
        .navigationTitle("アカウントの設定")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.surfacePrimary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
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

private extension WithdrawalConfirmationView {
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
}

fileprivate extension GeometryProxy {
    var itemWidth: CGFloat {
        return max(self.size.width - 32, 0)
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return NavigationStack {
        appDC.makeWithdrawalConfirmationView(isShowing: .constant(true))
    }
}
