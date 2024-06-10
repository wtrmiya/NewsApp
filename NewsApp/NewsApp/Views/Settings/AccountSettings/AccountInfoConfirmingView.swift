//
//  AccountInfoConfirmingView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/10.
//

import SwiftUI

struct AccountInfoConfirmingView: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("表示名")
                    Text("変更後: Yamada Tarou New")
                }
                Spacer()
            }
            Spacer()
                .frame(height: 30)
            HStack {
                VStack(alignment: .leading) {
                    Text("Email")
                    Text("変更後: ytaronew@example.com")
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
                    AccountInfoUpdateCompletionView(isShowing: $isShowing)
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
    NavigationStack {
        AccountInfoConfirmingView(isShowing: .constant(true))
    }
}
