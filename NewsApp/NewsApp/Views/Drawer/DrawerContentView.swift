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

    @ObservedObject private var authViewModel: AuthViewModel
    
    @Binding var isShowing: Bool
    @EnvironmentObject private var appDependencyContainer: AppDependencyContainer
    
    init(isShowing: Binding<Bool>, authViewModel: AuthViewModel) {
        self._isShowing = isShowing
        self.authViewModel = authViewModel
    }
    
    private var isSignedIn: Bool {
        authViewModel.signedInUser != nil
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                if let user = authViewModel.signedInUser {
                    VStack {
                        Spacer()
                            .frame(height: 48)
                        HStack {
                            Image(systemName: "person")
                                .font(.system(size: 16, weight: .medium))
                            Text(user.displayName)
                                .font(.system(size: 16, weight: .medium))
                            Spacer()
                        }
                        .padding(.leading, 16)
                    }
                } else {
                    VStack {
                        Spacer()
                            .frame(height: 50)
                        Button(action: {
                            isShowingSignUpView = true
                        }, label: {
                            Text("サインアップ")
                                .frame(width: proxy.size.width - 32, height: 48)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.titleNormal)
                                .background(.accent)
                        })
                        Button(action: {
                            isShowingSignInView = true
                        }, label: {
                            Text("サインイン")
                                .frame(width: proxy.size.width - 32, height: 48)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.titleNormal)
                                .overlay {
                                    Rectangle()
                                        .stroke(Color.borderNormal, lineWidth: 1)
                                }
                        })
                    }
                }
                
                Spacer()
                menuBorder(proxy: proxy)
                Button(action: {
                    isShowingSettingsView = true
                }, label: {
                    HStack {
                        Text("設定")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.black)
                })
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                menuBorder(proxy: proxy)
                Button(action: {
                    isShowingTermView = true
                }, label: {
                    HStack {
                        Text("利用規約")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.black)
                })
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                menuBorder(proxy: proxy)
                Button(action: {
                    isShowingLicenseListView = true
                }, label: {
                    HStack {
                        Text("ライセンス")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.black)
                })
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                menuBorder(proxy: proxy)
                Spacer()
                    .frame(height: 50)
                Button(action: {
                    isShowingSignOutAlert = true
                }, label: {
                    Text("サインアウト")
                        .frame(width: proxy.size.width - 32, height: 48)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isSignedIn ? Color.titleNormal : Color.disabled)
                        .overlay {
                            Rectangle()
                                .stroke(isSignedIn ? Color.borderNormal : Color.borderDisabled, lineWidth: 1)
                        }
                })
                .disabled(!isSignedIn)
                Spacer()
                    .frame(height: 16)
            }
        }
        .fullScreenCover(isPresented: $isShowingSettingsView) {
            appDependencyContainer.makeSettingsView(isShowing: $isShowingSettingsView)
        }
        .fullScreenCover(isPresented: $isShowingTermView) {
            appDependencyContainer.makeTermView(isShowing: $isShowingTermView)
        }
        .fullScreenCover(isPresented: $isShowingLicenseListView) {
            LicenseView(isShowing: $isShowingLicenseListView)
        }
        .fullScreenCover(isPresented: $isShowingSignUpView) {
            appDependencyContainer.makeSignUpView(isShowing: $isShowingSignUpView)
        }
        .fullScreenCover(isPresented: $isShowingSignInView) {
            appDependencyContainer.makeSignInView(isShowing: $isShowingSignInView)
        }
        .alert("現在サインイン中です\nサインアウトしますか", isPresented: $isShowingSignOutAlert) {
            Button(role: .cancel, action: {
                isShowing = false
            }, label: {
                Text("キャンセル")
            })
            Button(action: {
                authViewModel.signOut()
                isShowing = false
            }, label: {
                Text("サインアウト")
            })
        }
    }
    
    private func menuBorder(proxy: GeometryProxy) -> some View {
        Rectangle()
            .fill(Color.thickLine)
            .frame(width: proxy.size.width, height: 8)
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeDrawerContentView(isShowing: .constant(true))
}
