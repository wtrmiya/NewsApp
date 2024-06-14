//
//  PushNotificationSettingsView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct PushNotificationSettingsView: View {
    @Binding var isShowing: Bool
    @ObservedObject private var settingsViewModel: SettingsViewModel
    
    init(isShowing: Binding<Bool>, settingsViewModel: SettingsViewModel) {
        self._isShowing = isShowing
        self.settingsViewModel = settingsViewModel
    }
    
    var body: some View {
        List {
            Toggle("朝のニュース", isOn: $settingsViewModel.userSettings.pushMorningEnabled)
            Toggle("昼のニュース", isOn: $settingsViewModel.userSettings.pushAfternoonEnabled)
            Toggle("夕方のニュース", isOn: $settingsViewModel.userSettings.pushEveningEnabled)
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
    let appDC = AppDependencyContainer()
    return NavigationStack {
        appDC.makePushNotificationSettingsView(isShowing: .constant(true))
    }
}
