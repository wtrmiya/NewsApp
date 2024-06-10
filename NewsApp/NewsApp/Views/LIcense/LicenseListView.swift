//
//  LicenseView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct LicenseListView: View {
    let dummyLicenses = [
        "xxxLibrary",
        "yyyLibrary"
    ]
    
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dummyLicenses, id: \.self) { license in
                    NavigationLink {
                        LicenseDetailView(isShowing: $isShowing)
                    } label: {
                        Text(license)
                    }
                }
            }
            .navigationTitle("License")
            .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    LicenseListView(isShowing: .constant(true))
}
