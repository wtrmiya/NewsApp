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
    @State private var offsetX: CGFloat = -250

    var body: some View {
        ZStack(alignment: .leading) {
            if isShowing {
                Rectangle()
                    .background(.black)
                    .opacity(opacity)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.1)) {
                            offsetX = -250
                        }
                        withAnimation(.easeOut(duration: 0.2)) {
                            isShowing = false
                        }
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            opacity = 0.2
                        }
                    }
                
                DrawerContentView()
                    .frame(width: 250)
                    .background(.white)
                    .offset(x: offsetX)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.2)) {
                            offsetX = 0
                        }
                    }
            }
        }
    }
}

#Preview {
    DrawerView(isShowing: .constant(true))
}
