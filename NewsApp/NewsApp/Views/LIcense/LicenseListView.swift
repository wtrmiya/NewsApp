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
    var body: some View {
        NavigationStack {
            List {
                ForEach(dummyLicenses, id: \.self) { license in
                    Text(license)
                }
            }
            .navigationTitle("License")
            .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    LicenseListView()
}
