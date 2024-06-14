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
    @State private var isShowingSignUpView: Bool = false
    @State private var isShowingSignInView: Bool = false
    @State private var isShowingSignOutAlert: Bool = false

    @ObservedObject private var drawerViewModel: DrawerViewModel
    
    @Binding var isShowing: Bool
    @Environment(\.dismiss) private var dismiss
    
    init(isShowing: Binding<Bool>, drawerViewModel: DrawerViewModel) {
        self._isShowing = isShowing
        self.drawerViewModel = drawerViewModel
    }

    var body: some View {
        VStack {
            if let user = drawerViewModel.sidnedInUser {
                HStack {
                    Text(user.displayName)
                    Spacer()
                }
            } else {
                HStack {
                    Button(action: {
                        isShowingSignUpView = true
                    }, label: {
                        Text("Sign Up")
                    })
                    Button(action: {
                        isShowingSignInView = true
                    }, label: {
                        Text("Sign In")
                    })
                }
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
            LicenseView(isShowing: $isShowingLicenseListView)
        }
        .fullScreenCover(isPresented: $isShowingSignUpView) {
            SignUpView()
        }
        .fullScreenCover(isPresented: $isShowingSignInView) {
            SignInView()
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
    let appDC = AppDependencyContainer()
    return appDC.makeDrawerContentView(isShowing: .constant(true))
}
