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
    @State private var isShowingSignInCompletionAlert: Bool = false
    @FocusState private var focusField: Field?
    
    @Binding var isShowing: Bool
    @ObservedObject private var authViewModel: AuthViewModel
    
    init(isShowing: Binding<Bool>, authViewModel: AuthViewModel) {
        self._isShowing = isShowing
        self.authViewModel = authViewModel
    }

    var body: some View {
        ZStack(alignment: .top) {
            Text("サインイン")
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
                }
                
                Spacer()
                    .frame(height: 30)

                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            await signIn()
                        }
                    }, label: {
                        Text("サインイン")
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
        .onAppear {
            focusField = .email
        }
        .padding()
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
        .alert("サインインしました", isPresented: $isShowingSignInCompletionAlert, actions: {
            Button(action: {
                authViewModel.confirmSignedIn()
            }, label: {
                Text("OK")
            })
        })
        .onReceive(authViewModel.$signedInUser, perform: { value in
            if value != nil {
                isShowingSignInCompletionAlert = true
            }
        })
        .onReceive(authViewModel.$didSignedInConfirmed, perform: { didConfirmed in
            if didConfirmed {
                isShowing = false
            }
        })
    }
    
    private func signIn() async {
        await authViewModel.signIn()
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeSignInView(isShowing: .constant(true))
}
