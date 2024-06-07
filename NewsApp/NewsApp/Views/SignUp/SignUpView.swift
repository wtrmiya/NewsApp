//
//  SignUpView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var signUpViewModel = SignUpViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            Text("Sign Up")
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Button(action: {
                        print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
                    }, label: {
                        Text("Cancel")
                    })
                }

                VStack {
                    VStack(alignment: .leading) {
                        Text("Display Name")
                        TextField("Input display name", text: $signUpViewModel.displayName)
                            .textFieldStyle(.roundedBorder)
                    }
                    VStack(alignment: .leading) {
                        Text("Email")
                        TextField("Input email", text: $signUpViewModel.email)
                            .textFieldStyle(.roundedBorder)
                    }
                    VStack(alignment: .leading) {
                        Text("Password")
                        TextField("Input password", text: $signUpViewModel.password)
                            .textFieldStyle(.roundedBorder)
                    }
                    VStack(alignment: .leading) {
                        Text("Confirm Password")
                        TextField("Confirm password", text: $signUpViewModel.passwordRepeated)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                Text("全ての項目に情報を入力してください")

                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            await signUp()
                        }
                    }, label: {
                        Text("Create User")
                    })
                    Spacer()
                }

                Spacer()
            }
        }
        .padding()
    }
    
    private func signUp() async {
        await signUpViewModel.signUp()
    }
}

#Preview {
    SignUpView()
}
