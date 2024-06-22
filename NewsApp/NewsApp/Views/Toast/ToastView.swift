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
                    .frame(width: 250, height: 50)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .transition(.move(edge: .bottom))
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
