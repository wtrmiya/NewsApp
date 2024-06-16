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
    @EnvironmentObject private var appDependenciyContainer: AppDependencyContainer
    
    init(isShowing: Binding<Bool>, accountSettingsViewModel: AccountSettingsViewModel) {
        self._isShowing = isShowing
        self.accountSettingsViewModel = accountSettingsViewModel
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    if let userAccount = accountSettingsViewModel.userAccount {
                        Text("サインイン中のアカウント")
                        Text(userAccount.displayName)
                        Text(userAccount.email)
                    }
                }
                Spacer()
            }
            
            Spacer()
                .frame(height: 50)
            
            NavigationLink {
                appDependenciyContainer.makeAccountInfoEditingView(isShowing: $isShowing)
                    .navigationBarBackButtonHidden()
            } label: {
                Text("アカウント情報の編集")
            }
            Button(action: {
                isShowingConfirmSignOutAlert = true
            }, label: {
                Text("サインアウト")
            })
            
            Spacer()
            
            NavigationLink {
                appDependenciyContainer.makeWithdrawalConfirmationView(isShowing: $isShowing)
            } label: {
                Text("退会する")
            }
        }
        .padding()
        .alert("Yamada Tarou\nでサインイン中です。\nサインアウトしますか", isPresented: $isShowingConfirmSignOutAlert, actions: {
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
        .task {
            accountSettingsViewModel.populateUserAccount()
        }
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return NavigationStack {
        appDC.makeAccountSettingsView(isShowing: .constant(true))
    }
}
