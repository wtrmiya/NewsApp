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
        VStack {
            Text("記事タイトルが入ります記事タイトルが入ります記事タイトルが入ります記事タイトルが入ります")
            Spacer()
                .frame(height: 40)
            Text("記事本文が入ります記事本文が入ります記事本文が入ります記事本文が入ります記事本文が入ります記事本文が入ります")
            Spacer()
            
            VStack {
                Text("サイズ")
                Text(settingsViewModel.userSettings.letterSize.description)
                HStack {
                    Button(action: {
                        print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
                    }, label: {
                        Text("小")
                    })
                    Button(action: {
                        print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
                    }, label: {
                        Text("中")
                    })
                    Button(action: {
                        print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
                    }, label: {
                        Text("大")
                    })
                }
            }
            VStack {
                Text("太さ")
                Text(settingsViewModel.userSettings.letterWeight.description)
                HStack {
                    Button(action: {
                        print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
                    }, label: {
                        Text("通常")
                    })
                    Button(action: {
                        print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
                    }, label: {
                        Text("太い")
                    })
                }
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
