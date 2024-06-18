//
//  LicenseView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI
import LicenseList

struct LicenseView: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationStack {
            LicenseListView()
            .navigationTitle("ライセンス")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowing = false
                    }, label: {
                        Text("閉じる")
                    })
                }
            }
        }
    }
}

#Preview {
    LicenseView(isShowing: .constant(true))
}
