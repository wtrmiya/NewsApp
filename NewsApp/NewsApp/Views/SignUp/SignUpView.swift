//
//  SignUpView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct SignUpView: View {
    enum Field: Hashable {
        case displayName
        case email
        case password
        case passwordRepeated
    }
    
    @State private var isShowingAlert: Bool = false
    @Binding var isShowing: Bool
    @FocusState private var focusField: Field?
    
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
                        
                        notice(proxy: proxy)
                        signUpButton(proxy: proxy)
                        Spacer()
                    }
                }
            }
            .navigationTitle("サインアップ")
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
            focusField = .displayName
        }
        .alert("Error", isPresented: $isShowingAlert, actions: {
            Button(action: {
                isShowingAlert = false
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
    
    private func signUp() async {
        await authViewModel.signUp()
    }
}

// MARK: - View Components
private extension SignUpView {
    func forms(proxy: GeometryProxy) -> some View {
        VStack {
            userNameForm(proxy: proxy)
            Spacer()
                .frame(height: 32)
            emailAddressForm(proxy: proxy)
            Spacer()
                .frame(height: 32)
            passwordForm(proxy: proxy)
            Spacer()
                .frame(height: 32)
            passwordConfirmationForm(proxy: proxy)
        }
    }
    
    func userNameForm(proxy: GeometryProxy) -> some View {
        textForm(
            title: "ユーザ名",
            placeholder: "ユーザ名を入力してください",
            textBinding: $authViewModel.displayName,
            proxy: proxy,
            focusState: $focusField,
            focusValue: .displayName
        )
    }

    func emailAddressForm(proxy: GeometryProxy) -> some View {
        textForm(
            title: "Emailアドレス",
            placeholder: "Emailアドレスを入力してください",
            textBinding: $authViewModel.email,
            proxy: proxy,
            focusState: $focusField,
            focusValue: .email
        )
    }
    
    func passwordForm(proxy: GeometryProxy) -> some View {
        textForm(
            title: "パスワード",
            placeholder: "パスワードを入力してください",
            textBinding: $authViewModel.password,
            proxy: proxy,
            focusState: $focusField,
            focusValue: .password
        )
    }
    
    func passwordConfirmationForm(proxy: GeometryProxy) -> some View {
        textForm(
            title: "パスワードの確認入力",
            placeholder: "パスワードを再度入力してください",
            textBinding: $authViewModel.passwordRepeated,
            proxy: proxy,
            focusState: $focusField,
            focusValue: .passwordRepeated
        )
    }
    
    // swiftlint:disable:next function_parameter_count line_length
    func textForm(title: String, placeholder: String, textBinding: Binding<String>, proxy: GeometryProxy, focusState: FocusState<Field?>.Binding, focusValue: Field) -> some View {
        // swiftlint:disable:previous function_parameter_count line_length
        VStack(alignment: .leading) {
            Text(title)
                .font(
                    .system(
                        size: settingsViewModel.userSettings.letterSize.bodyLetterSize,
                        weight: settingsViewModel.userSettings.letterWeight.bodyLetterWeight
                    )
                )
            TextField(placeholder, text: textBinding)
                .standardTextFieldModifier(width: proxy.itemWidth)
                .focused(focusState, equals: focusValue)
        }
    }
    
    func notice(proxy: GeometryProxy) -> some View {
        HStack {
            Text("全ての項目に情報を入力してください")
            Spacer()
        }
        .frame(width: proxy.itemWidth)
    }
    
    func signUpButton(proxy: GeometryProxy) -> some View {
        Button(action: {
            Task {
                await signUp()
            }
        }, label: {
            Text("サインアップ")
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
    return appDC.makeSignUpView(isShowing: .constant(true))
}
