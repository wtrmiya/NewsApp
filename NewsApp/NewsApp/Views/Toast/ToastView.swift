//
//  ToastView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/22.
//

import SwiftUI

struct ToastView: View {
    @ObservedObject var toastHandler: ToastHandler
    
    private var toastHidingDuration: Duration {
        .milliseconds(10)
    }
    
    var body: some View {
        Group {
            if let toastMessage = toastHandler.currentToastMessage {
                Text(toastMessage)
                    .frame(width: 300, height: 50)
                    .font(.footnote)
                    .foregroundStyle(.white)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .transition(.toastMove.combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: toastHandler.currentToastMessage)
        .onTapGesture {
            toastHandler.skipCurrent(in: toastHidingDuration)
        }
    }
}

extension View {
    func displayToast(handledBy toastHandler: ToastHandler) -> some View {
        self.displayToast(
            on: .bottom,
            handledBy: toastHandler,
            toastMaker: { ToastView(toastHandler: $0) }
        )
    }
}

fileprivate extension AnyTransition {
    private struct YOffsetModifier: ViewModifier {
        let yOffset: CGFloat
        
        func body(content: Content) -> some View {
            content
                .offset(y: yOffset)
        }
    }
    
    static var toastMove: AnyTransition {
        AnyTransition.modifier(
            active: YOffsetModifier(yOffset: 0),
            identity: YOffsetModifier(yOffset: -70)
        )
    }
}
