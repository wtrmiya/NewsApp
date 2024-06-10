//
//  DrawerContentView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct DrawerContentView: View {
    @State private var isShowingSettingsView: Bool = false
    @State private var isShowingTermView: Bool = false
    @State private var isShowingLicenseListView: Bool = false
    @State private var isShowingSignOutAlert: Bool = false
    
    @StateObject private var drawerViewModel: DrawerViewModel = DrawerViewModel()
    
    @Binding var isShowing: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            HStack {
                Text("Yamada Tarou")
                Spacer()
            }
            
            Spacer()
                .frame(height: 50)
            Divider()
            Button(action: {
                print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
            }, label: {
                HStack {
                    Text("Bookmark")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            })
            Divider()
            Spacer()
            Divider()
            Button(action: {
                isShowingSettingsView = true
            }, label: {
                HStack {
                    Text("Settings")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            })
            Divider()
            Button(action: {
                isShowingTermView = true
            }, label: {
                HStack {
                    Text("Terms")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            })
            Divider()
            Button(action: {
                isShowingLicenseListView = true
            }, label: {
                HStack {
                    Text("Licenses")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            })
            Divider()
            Spacer()
                .frame(height: 50)
            Divider()
            Button(action: {
                isShowingSignOutAlert = true
            }, label: {
                HStack {
                    Text("Sign Out")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            })
            Divider()
        }
        .padding()
        .fullScreenCover(isPresented: $isShowingSettingsView) {
            SettingsView(isShowing: $isShowingSettingsView)
        }
        .fullScreenCover(isPresented: $isShowingTermView) {
            TermView(isShowing: $isShowingTermView)
        }
        .fullScreenCover(isPresented: $isShowingLicenseListView) {
            LicenseListView(isShowing: $isShowingLicenseListView)
        }
        .alert("現在サインイン中です\nサインアウトしますか", isPresented: $isShowingSignOutAlert) {
            Button(role: .cancel, action: {
                isShowing = false
                dismiss()
            }, label: {
                Text("Cancel")
            })
            Button(action: {
                drawerViewModel.signOut()
            }, label: {
                Text("Sign Out")
            })
        }
    }
}

#Preview {
    DrawerContentView(isShowing: .constant(true))
}
