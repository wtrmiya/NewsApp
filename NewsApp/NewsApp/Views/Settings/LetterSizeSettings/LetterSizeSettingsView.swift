//
//  LetterSizeSettingsView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct LetterSizeSettingsView: View {
    @Binding var isShowing: Bool
    
    @ObservedObject private var settingsViewModel: SettingsViewModel
    init(isShowing: Binding<Bool>, settingsViewModel: SettingsViewModel) {
        self._isShowing = isShowing
        self.settingsViewModel = settingsViewModel
    }

    var body: some View {
        Form {
            Section {
                Text("記事タイトルが入ります記事タイトルが入ります記事タイトルが入ります記事タイトルが入ります")
                    .font(
                        .system(
                            size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                            weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                        )
                    )
                Text("記事概要が入ります記事概要が入ります記事概要が入ります記事概要が入ります記事概要が入ります記事概要が入ります")
                    .font(
                        .system(
                            size: settingsViewModel.userSettings.letterSize.captionLetterSize,
                            weight: settingsViewModel.userSettings.letterWeight.thinLetterWeight
                        )
                    )
            }
            Section {
                Picker("文字のサイズ", selection: $settingsViewModel.userSettings.letterSize) {
                    ForEach(LetterSize.allCases, id: \.self) { letterSize in
                        Text(letterSize.description)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("文字のサイズ")
            }
            
            Section {
                Picker("文字の太さ", selection: $settingsViewModel.userSettings.letterWeight) {
                    ForEach(LetterWeight.allCases, id: \.self) { letterWeight in
                        Text(letterWeight.description)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("文字の太さ")
            }
        }
        .navigationTitle("文字サイズの設定")
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
        return appDC.makeLetterSizeSettingsView(isShowing: .constant(true))
    }
}
