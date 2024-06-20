//
//  SignInView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct SignInView: View {
    @State private var isShowingAlert: Bool = false
    
    @Binding var isShowing: Bool
    @ObservedObject private var signInViewModel: SignInViewModel
    
    init(isShowing: Binding<Bool>, signInViewModel: SignInViewModel) {
        self._isShowing = isShowing
        self.signInViewModel = signInViewModel
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
                        TextField("Emailアドレスを入力してください", text: $signInViewModel.email)
                            .textFieldStyle(.roundedBorder)
                    }
                    Spacer()
                        .frame(height: 20)
                    VStack(alignment: .leading) {
                        Text("パスワード")
                        TextField("パスワードを入力してください", text: $signInViewModel.password)
                            .textFieldStyle(.roundedBorder)
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
        .padding()
        .alert("Error", isPresented: $isShowingAlert, actions: {
            Button(action: {
                isShowing = false
            }, label: {
                Text("OK")
            })
        }, message: {
            if let errorMessage = signInViewModel.errorMessage {
                Text(errorMessage)
            }
        })
        .onReceive(signInViewModel.$errorMessage, perform: { _ in
            if signInViewModel.errorMessage != nil {
                isShowingAlert = true
            }
        })
    }
    
    private func signIn() async {
        await signInViewModel.signIn()
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeSignInView(isShowing: .constant(true))
}
