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
    
    init(isShowing: Binding<Bool>, authViewModel: AuthViewModel) {
        self._isShowing = isShowing
        self.authViewModel = authViewModel
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let itemWidth = max(proxy.size.width - 32, 0)
                ZStack {
                    Color.surfacePrimary
                    VStack {
                        Spacer()
                            .frame(height: 32)
                        VStack(alignment: .leading) {
                            Text("ユーザ名")
                                .font(.system(size: 16, weight: .medium))
                            TextField("ユーザ名を入力してください", text: $authViewModel.displayName)
                                .padding(8)
                                .frame(width: itemWidth, height: 48)
                                .background(.textFieldBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .textInputAutocapitalization(.never)
                                .font(.system(size: 16, weight: .regular))
                                .autocorrectionDisabled(true)
                                .focused($focusField, equals: .displayName)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.border, lineWidth: 1)
                                }
                        }
                        Spacer()
                            .frame(height: 32)
                        VStack(alignment: .leading) {
                            Text("Emailアドレス")
                                .font(.system(size: 16, weight: .medium))
                            TextField("Emailアドレスを入力してください", text: $authViewModel.email)
                                .padding(8)
                                .frame(width: itemWidth, height: 48)
                                .background(.textFieldBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .textInputAutocapitalization(.never)
                                .font(.system(size: 16, weight: .regular))
                                .autocorrectionDisabled(true)
                                .focused($focusField, equals: .email)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.border, lineWidth: 1)
                                }
                        }
                        
                        Spacer()
                            .frame(height: 32)
                        VStack(alignment: .leading) {
                            Text("パスワード")
                                .font(.system(size: 16, weight: .medium))
                            TextField("パスワードを入力してください", text: $authViewModel.password)
                                .padding(8)
                                .frame(width: itemWidth, height: 48)
                                .background(.textFieldBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .textInputAutocapitalization(.never)
                                .font(.system(size: 16, weight: .regular))
                                .autocorrectionDisabled(true)
                                .focused($focusField, equals: .password)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.border, lineWidth: 1)
                                }
                        }
                        
                        Spacer()
                            .frame(height: 32)
                        VStack(alignment: .leading) {
                            Text("パスワードの確認入力")
                                .font(.system(size: 16, weight: .medium))
                            TextField("パスワードを再度入力してください", text: $authViewModel.passwordRepeated)
                                .padding(8)
                                .frame(width: itemWidth, height: 48)
                                .background(.textFieldBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .textInputAutocapitalization(.never)
                                .font(.system(size: 16, weight: .regular))
                                .autocorrectionDisabled(true)
                                .focused($focusField, equals: .passwordRepeated)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.border, lineWidth: 1)
                                }
                        }
                        
                        Spacer()
                            .frame(height: 48)
                        
                        HStack {
                            Text("全ての項目に情報を入力してください")
                            Spacer()
                        }
                        .frame(width: itemWidth)
                        
                        Button(action: {
                            Task {
                                await signUp()
                            }
                        }, label: {
                            Text("サインアップ")
                                .frame(width: itemWidth, height: 48)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.titleNormal)
                                .background(.accent)
                        })
                        
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

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeSignUpView(isShowing: .constant(true))
}
