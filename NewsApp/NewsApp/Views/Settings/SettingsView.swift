//
//  SettingsView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isShowing: Bool
    @EnvironmentObject private var appDependencyContainer: AppDependencyContainer
    @ObservedObject private var settingsViewModel: SettingsViewModel
    
    init(isShowing: Binding<Bool>, settingsViewModel: SettingsViewModel) {
        self._isShowing = isShowing
        self.settingsViewModel = settingsViewModel
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        appDependencyContainer.makePushNotificationSettingsView(isShowing: $isShowing)
                    } label: {
                        HStack {
                            Text("PUSH通知の設定")
                            Spacer()
                            Text(settingsViewModel.userSettings.pushSettingsDescription)
                        }
                    }
                } header: {
                    Text("PUSH")
                }
                Section {
                    NavigationLink {
                        LetterSizeSettingsView(isShowing: $isShowing)
                    } label: {
                        HStack {
                            Text("文字サイズの設定")
                            Spacer()
                            Text("中")
                        }
                    }
                    NavigationLink {
                        DarkModeSettingsView(isShowing: $isShowing)
                    } label: {
                        HStack {
                            Text("ダークモードの設定")
                            Spacer()
                            Text("端末の設定")
                        }
                    }
                } header: {
                    Text("APPEARANCE")
                }
                Section {
                    NavigationLink {
                        AccountSettingsView(isShowing: $isShowing)
                    } label: {
                        HStack {
                            Text("アカウントの設定")
                            Spacer()
                            Text("サインイン中")
                        }
                    }
                } header: {
                    Text("ACCOUNT")
                }
            }
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
        .task {
            await settingsViewModel.populateUserSettings()
        }
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeSettingsView(isShowing: .constant(true))
}
