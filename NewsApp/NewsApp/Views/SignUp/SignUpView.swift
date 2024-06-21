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
        ZStack(alignment: .top) {
            Text("サインアップ")
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Button(action: {
                        isShowing = false
                    }, label: {
                        Text("閉じる")
                    })
                }
                
                Spacer()
                    .frame(height: 30)

                VStack {
                    VStack(alignment: .leading) {
                        Text("表示名")
                        TextField("表示名を入力してください", text: $authViewModel.displayName)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusField, equals: .displayName)
                    }
                    Spacer()
                        .frame(height: 20)
                    VStack(alignment: .leading) {
                        Text("Emailアドレス")
                        TextField("Emailアドレスを入力してください", text: $authViewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusField, equals: .email)
                    }
                    Spacer()
                        .frame(height: 20)
                    VStack(alignment: .leading) {
                        Text("パスワード")
                        TextField("パスワードを入力してください", text: $authViewModel.password)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusField, equals: .password)
                    }
                    Spacer()
                        .frame(height: 20)
                    VStack(alignment: .leading) {
                        Text("確認用パスワード")
                        TextField("パスワードを再度入力してください", text: $authViewModel.passwordRepeated)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusField, equals: .passwordRepeated)
                    }
                }
                
                Spacer()
                    .frame(height: 20)

                Text("全ての項目に情報を入力してください")

                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            await signUp()
                        }
                    }, label: {
                        Text("サインアップ")
                            .foregroundStyle(.white)
                            .frame(width: 150, height: 50)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    })
                    Spacer()
                }

                Spacer()
            }
        }
        .padding()
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
