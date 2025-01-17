//
//  AccountInfoUpdateCompletionView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/10.
//

import SwiftUI

struct AccountInfoUpdateCompletionView: View {
    @Binding var isShowing: Bool
    
    init(isShowing: Binding<Bool>) {
        self._isShowing = isShowing
    }
    
    var body: some View {
        VStack {
            Text("アカウント情報を更新しました。")
            Spacer()
                .frame(height: 100)
            Button(action: {
                isShowing = false
            }, label: {
                Text("ホームへ")
            })
        }
        .padding()
        .navigationTitle("アカウントの設定")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isShowing = false
                }, label: {
                    Text("閉じる")
                })
            }
        }
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return NavigationStack {
        appDC.makeAccountInfoUpdateCompletionView(isShowing: .constant(true))
    }
}
