//
//  WithdrawalConfirmationView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct WithdrawalConfirmationView: View {
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
            
            Text("ユーザを登録したままにしていただけると、\nブックマークやお知らせなど便利な機能が継続してご使用になれます")
            
            Spacer()
            
            Button(action: {
                print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
            }, label: {
                Text("退会する")
            })
        }
        .padding()
        .navigationTitle("アカウントの設定")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
                }, label: {
                    Text("Dismiss")
                })
            }
        }
    }
}

#Preview {
    NavigationStack {
        WithdrawalConfirmationView()
    }
}
