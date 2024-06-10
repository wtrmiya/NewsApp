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

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("サインイン中のアカウント")
                    Text("Yamada Tarou")
                    Text("ytaro@example.com")
                }
                Spacer()
            }
            
            Spacer()
                .frame(height: 50)
            
            NavigationLink {
                AccountInfoEditingView(isShowing: $isShowing)
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
                WithdrawalConfirmationView()
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
    }
}

#Preview {
    NavigationStack {
        AccountSettingsView(isShowing: .constant(true))
    }
}
