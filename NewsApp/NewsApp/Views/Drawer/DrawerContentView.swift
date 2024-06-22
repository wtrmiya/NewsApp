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
        VStack {
            if let user = authViewModel.signedInUser {
                VStack {
                    Spacer()
                        .frame(height: 50)
                    HStack {
                        Image(systemName: "person")
                        Text(user.displayName)
                        Spacer()
                    }
                }
            } else {
                VStack {
                    Spacer()
                        .frame(height: 50)
                    Button(action: {
                        isShowingSignUpView = true
                    }, label: {
                        Text("サインアップ")
                            .foregroundStyle(.white)
                            .frame(width: 150, height: 50)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    })
                    Button(action: {
                        isShowingSignInView = true
                    }, label: {
                        Text("サインイン")
                            .foregroundStyle(.blue)
                            .frame(width: 150, height: 50)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            }
                    })
                }
            }
            
            Spacer()
            Divider()
            Button(action: {
                isShowingSettingsView = true
            }, label: {
                HStack {
                    Text("設定")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.black)
            })
            Divider()
            Button(action: {
                isShowingTermView = true
            }, label: {
                HStack {
                    Text("利用規約")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.black)
            })
            Divider()
            Button(action: {
                isShowingLicenseListView = true
            }, label: {
                HStack {
                    Text("ライセンス")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.black)
            })
            Divider()
            Spacer()
                .frame(height: 50)
            Button(action: {
                isShowingSignOutAlert = true
            }, label: {
                Text("サインアウト")
                    .foregroundStyle(isSignedIn ? .blue : .gray)
                    .frame(width: 150, height: 50)
                    .background(isSignedIn ? .white : .gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSignedIn ? Color.blue : .gray.opacity(0.1), lineWidth: 1)
                    }
            })
            .disabled(!isSignedIn)
        }
        .padding()
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
}

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeDrawerContentView(isShowing: .constant(true))
}
