//
//  PushNotificationSettingsView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct PushNotificationSettingsView: View {
    @State private var morningNewsEnabled: Bool = true
    @State private var afternoonNewsEnabled: Bool = true
    @State private var eveningNewsEnabled: Bool = true
    
    @Binding var isShowing: Bool
    
    var body: some View {
        List {
            Toggle("朝のニュース", isOn: $morningNewsEnabled)
            Toggle("昼のニュース", isOn: $afternoonNewsEnabled)
            Toggle("夕方のニュース", isOn: $eveningNewsEnabled)
        }
        .navigationTitle("PUSH通知の設定")
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
        PushNotificationSettingsView(isShowing: .constant(true))
    }
}
