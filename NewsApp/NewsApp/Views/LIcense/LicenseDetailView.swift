//
//  LicenseDetailView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct LicenseDetailView: View {
    var body: some View {
        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
                    }, label: {
                        Text("Dismiss")
                    })
                }
            }
    }
}

#Preview {
    LicenseDetailView()
}
