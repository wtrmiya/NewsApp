//
//  LicenseDetailView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct LicenseDetailView: View {
    @Binding var isShowing: Bool
    var body: some View {
        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowing = false
                    }, label: {
                        Text("Dismiss")
                    })
                }
            }
    }
}

#Preview {
    LicenseDetailView(isShowing: .constant(true))
}
