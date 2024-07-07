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
    @ObservedObject private var authViewModel: AuthViewModel

    init(
        isShowing: Binding<Bool>,
        settingsViewModel: SettingsViewModel,
        authViewModel: AuthViewModel
    ) {
        self._isShowing = isShowing
        self.settingsViewModel = settingsViewModel
        self.authViewModel = authViewModel
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
                }.disabled(authViewModel.signedInUser == nil)
                Section {
                    NavigationLink {
                        appDependencyContainer.makeLetterSizeSettingsView(isShowing: $isShowing)
                    } label: {
                        HStack {
                            Text("文字サイズの設定")
                            Spacer()
                            Text(settingsViewModel.userSettings.letterSettingsDescription)
                        }
                    }
                    NavigationLink {
                        appDependencyContainer.makeDarkModeSettingsView(isShowing: $isShowing)
                    } label: {
                        HStack {
                            Text("ダークモードの設定")
                            Spacer()
                            Text(settingsViewModel.userSettings.darkModeDescription)
                        }
                    }
                } header: {
                    Text("APPEARANCE")
                }
                Section {
                    NavigationLink {
                        LicenseView(isShowing: $isShowing)
                    } label: {
                        HStack {
                            Text("ライセンス")
                        }
                    }
                } header: {
                    Text("LICENSE")
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
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeSettingsView(isShowing: .constant(true))
}
