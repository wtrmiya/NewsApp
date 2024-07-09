//
//  SignInView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct SignInView: View {
    enum Field: Hashable {
        case email
        case password
    }
    
    @State private var isShowingAlert: Bool = false
    @FocusState private var focusField: Field?
    
    @Binding var isShowing: Bool
    @ObservedObject private var authViewModel: AuthViewModel
    @ObservedObject private var settingsViewModel: SettingsViewModel

    init(isShowing: Binding<Bool>, authViewModel: AuthViewModel, settingsViewModel: SettingsViewModel) {
        self._isShowing = isShowing
        self.authViewModel = authViewModel
        self.settingsViewModel = settingsViewModel
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ZStack {
                    Color.surfacePrimary
                    VStack {
                        Spacer()
                            .frame(height: 32)
                        forms(proxy: proxy)
                        Spacer()
                            .frame(height: 48)
                        signInButton(proxy: proxy)
                        Spacer()
                    }
                }
            }
            .navigationTitle("サインイン")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.surfacePrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowing = true
                    }, label: {
                        Text("閉じる")
                            .foregroundStyle(.titleNormal)
                    })
                }
            }
        }
        .onAppear {
            focusField = .email
        }
        .alert("Error", isPresented: $isShowingAlert, actions: {
            Button(action: {
                isShowing = false
            }, label: {
                Text("OK")
            })
        }, message: {
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
            }
        })
        .onReceive(authViewModel.$errorMessage, perform: { _ in
            if authViewModel.errorMessage != nil {
                isShowingAlert = true
            }
        })
        .onReceive(authViewModel.$signedInUser, perform: { value in
            if value != nil {
                isShowing = false
            }
        })
    }
    
    private func signIn() async {
        await authViewModel.signIn()
    }
}

// MARK: - View Components
private extension SignInView {
    @ViewBuilder
    private func forms(proxy: GeometryProxy) -> some View {
        VStack {
            emailAddressForm(proxy: proxy)
            Spacer()
                .frame(height: 32)
            passwordForm(proxy: proxy)
        }
    }
    
    private func emailAddressForm(proxy: GeometryProxy) -> some View {
        VStack(alignment: .leading) {
            Text("Emailアドレス")
                .font(
                    .system(
                        size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                        weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                    )
                )
            TextField("Emailアドレスを入力してください", text: $authViewModel.email)
                .standardTextFieldModifier(width: proxy.itemWidth)
                .focused($focusField, equals: .email)
        }
    }
    
    private func passwordForm(proxy: GeometryProxy) -> some View {
        VStack(alignment: .leading) {
            Text("パスワード")
                .font(
                    .system(
                        size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                        weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                    )
                )
            TextField("パスワードを入力してください", text: $authViewModel.password)
                .standardTextFieldModifier(width: proxy.itemWidth)
                .focused($focusField, equals: .password)
        }
    }

    @ViewBuilder
    private func signInButton(proxy: GeometryProxy) -> some View {
        Button(action: {
            Task {
                await signIn()
            }
        }, label: {
            Text("サインイン")
                .frame(width: proxy.itemWidth, height: 48)
                .font(
                    .system(
                        size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                        weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                    )
                )
                .foregroundStyle(.titleNormal)
                .background(.accent)
        })
    }
}

fileprivate extension GeometryProxy {
    var itemWidth: Double {
        return max(self.size.width - 32.0, 0)
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeSignInView(isShowing: .constant(true))
}
