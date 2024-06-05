//
//  DarkModeSettingsView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct DarkModeSettingsView: View {
    var body: some View {
        VStack {
            List {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("端末の設定に沿う")
                }
                HStack {
                    Image(systemName: "circle")
                    Text("常にライトモードを使用する")
                }
                HStack {
                    Image(systemName: "circle")
                    Text("常にダークモードを使用する")
                }
            }
        }
        .navigationTitle("ダークモードの設定")
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
        DarkModeSettingsView()
    }
}
