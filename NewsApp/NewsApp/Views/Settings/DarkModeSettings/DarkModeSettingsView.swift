//
//  DarkModeSettingsView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct DarkModeSettingsView: View {
    @Binding var isShowing: Bool
    @ObservedObject private var settingsViewModel: SettingsViewModel
    
    init(isShowing: Binding<Bool>, settingsViewModel: SettingsViewModel) {
        self._isShowing = isShowing
        self.settingsViewModel = settingsViewModel
    }

    var body: some View {
        VStack {
            List {
                Text(settingsViewModel.userSettings.darkMode.description)
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
                    isShowing = false
                }, label: {
                    Text("Dismiss")
                })
            }
        }
        .task {
            await settingsViewModel.populateUserSettings()
        }
    }
}

#Preview {
    NavigationStack {
        let appDC = AppDependencyContainer()
        return appDC.makeDarkModeSettingsView(isShowing: .constant(true))
    }
}
