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
            
            Text("ユーザを登録したままにしていただけると、\nブックマークやお知らせなど便利な機能が継続してご使用になれます")
            
            Spacer()
            
            Button(action: {
                isShowing = false
            }, label: {
                Text("退会せずこのまま使用する")
            })

            Button(action: {
                isShowingWithdrawalCompletionAlert = true
            }, label: {
                Text("退会する")
            })
        }
        .padding()
        .alert("退会しました。\nご利用ありがとうございました。", isPresented: $isShowingWithdrawalCompletionAlert, actions: {
            Button(action: {
                isShowing = false
            }, label: {
                Text("ホームへ")
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
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return NavigationStack {
        appDC.makeWithdrawalConfirmationView(isShowing: .constant(true))
    }
}
