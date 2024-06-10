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
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Text("Yamada Tarou")
                    Text("ytaro@example.com")
                } header: {
                    Text("サインイン中のアカウント")
                }
                
                Section {
                    TextField("Input New Name", text: $displayName)
                } header: {
                    Text("変更後の表示名")
                }
                
                Section {
                    TextField("Input New Email", text: $email)
                } header: {
                    Text("変更後のEmail")
                }
                
                Section {
                    SecureField("Input New Password", text: $password)
                } header: {
                    Text("変更後のパスワード")
                }
                Section {
                    SecureField("Repeat New Password", text: $repeatedPassword)
                } header: {
                    Text("パスワードの確認入力")
                }
            }
            NavigationLink {
                AccountInfoConfirmingView(isShowing: $isShowing)
            } label: {
                Text("変更内容の確認")
            }
        }
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
        AccountInfoEditingView(isShowing: .constant(true))
    }
}
