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
    
    private func isSelected(darkModeSetting: DarkModeSetting) -> Bool {
        return darkModeSetting == settingsViewModel.userSettings.darkMode
    }

    var body: some View {
        VStack {
            List {
                ForEach(DarkModeSetting.allCases, id: \.self) { colorScheme in
                    colorSchemeSettingItem(darkModeSetting: colorScheme)
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

// MARK: - View Components

private extension DarkModeSettingsView {
    func colorSchemeSettingItem(darkModeSetting: DarkModeSetting) -> some View {
        let isSelected: Bool
        if darkModeSetting == settingsViewModel.userSettings.darkMode {
            isSelected = true
        } else {
            isSelected = false
        }
        return HStack {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
            } else {
                Image(systemName: "circle")
            }
            Text(darkModeSetting.description)
        }
        .onTapGesture {
            settingsViewModel.userSettings.darkMode = darkModeSetting
        }
    }
}

#Preview {
    NavigationStack {
        let appDC = AppDependencyContainer()
        return appDC.makeDarkModeSettingsView(isShowing: .constant(true))
    }
}
