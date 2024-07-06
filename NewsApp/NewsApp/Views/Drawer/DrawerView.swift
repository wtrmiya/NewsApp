//
//  DrawerView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/10.
//

import SwiftUI

struct DrawerView: View {
    @Binding var isShowing: Bool
    @State private var opacity: CGFloat = 0.0
    @State private var offsetX: CGFloat = -256
    
    @EnvironmentObject private var appDependencyContainer: AppDependencyContainer
    
    private let openingDuration: CGFloat = 0.2
    private let closingDuration: CGFloat = 0.1
    private let drawerWidth: CGFloat = 256

    var body: some View {
        ZStack(alignment: .leading) {
            if isShowing {
                Rectangle()
                    .background(.surfacePrimary)
                    .opacity(opacity)
                    .onTapGesture {
                        closeDrawer()
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: openingDuration)) {
                            opacity = 0.2
                        }
                    }
                
                ZStack(alignment: .topLeading) {
                    appDependencyContainer.makeDrawerContentView(isShowing: $isShowing)
                        .frame(width: drawerWidth)
                        .background(.surfacePrimary)
                    HStack {
                        Spacer()
                        Button(action: {
                            closeDrawer()
                        }, label: {
                            Image(systemName: "multiply")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.titleNormal)
                        })
                        .padding()
                    }
                    .frame(width: drawerWidth)
                }
                .offset(x: offsetX)
                .onAppear {
                    withAnimation(.easeOut(duration: openingDuration)) {
                        offsetX = 0
                    }
                }
            }
        }
    }
    
    private func closeDrawer() {
        withAnimation(.easeOut(duration: closingDuration)) {
            offsetX = -drawerWidth
            isShowing = false
        }
    }
}

#Preview {
    DrawerView(isShowing: .constant(true))
}
