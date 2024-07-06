//
//  TextField+Extensions.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/07/07.
//

import SwiftUI

extension TextField {
    func standardTextFieldModifier(width: Double) -> some View {
        self
            .padding(8)
            .frame(width: width, height: 48)
            .background(.textFieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .textInputAutocapitalization(.never)
            .font(.system(size: 16, weight: .regular))
            .autocorrectionDisabled(true)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.border, lineWidth: 1)
            }
    }
}
