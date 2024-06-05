//
//  SettingsView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("PUSH通知の設定")
                        Spacer()
                        Text("受け取る")
                        Image(systemName: "chevron.right")
                    }
                }
                Section {
                    HStack {
                        Text("文字サイズの設定")
                        Spacer()
                        Text("中")
                        Image(systemName: "chevron.right")
                    }
                    HStack {
                        Text("ダークモードの設定")
                        Spacer()
                        Text("端末の設定")
                        Image(systemName: "chevron.right")
                    }
                }
                Section {
                    HStack {
                        Text("アカウントの設定")
                        Spacer()
                        Text("サインイン中")
                        Image(systemName: "chevron.right")
                    }
                }
            }
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
}

#Preview {
    SettingsView()
}
