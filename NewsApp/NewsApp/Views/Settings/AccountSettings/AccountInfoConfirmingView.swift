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
    
    @EnvironmentObject private var appDependencyContainer: AppDependencyContainer
    
    init(isShowing: Binding<Bool>, accountSettingsViewModel: AccountSettingsViewModel) {
        self._isShowing = isShowing
        self.accountSettingsViewModel = accountSettingsViewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("表示名")
                    if let inputUserAccount = accountSettingsViewModel.inputUserAccount {
                        Text("変更後: \(inputUserAccount.displayName)")
                    } else {
                        Text("変更なし")
                    }
                }
                Spacer()
            }
            Spacer()
                .frame(height: 30)
            HStack {
                VStack(alignment: .leading) {
                    Text("Email")
                    if let inputUserAccount = accountSettingsViewModel.inputUserAccount {
                        Text("変更後: \(inputUserAccount.email)")
                    } else {
                        Text("変更なし")
                    }
                }
                Spacer()
            }
            Spacer()
                .frame(height: 30)
            HStack {
                VStack(alignment: .leading) {
                    Text("パスワード")
                    Text("変更後: ●●●●●●")
                }
            }
            Spacer()
                .frame(height: 50)
            HStack {
                Spacer()
                NavigationLink {
                    appDependencyContainer.makeAccountInfoUpdateCompletionView(isShowing: $isShowing)
                        .navigationBarBackButtonHidden()
                } label: {
                    Text("変更を確定する")
                }
                Spacer()
            }
            Spacer()
        }
        .padding()
        .navigationTitle("アカウントの設定")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isShowing = false
                }, label: {
                    Text("Dismiss")
                })
            }
        }
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return NavigationStack {
        appDC.makeAccountInfoConfirmingView(isShowing: .constant(true))
    }
}
