//
//  ToastDisplayModifier.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/22.
//

import SwiftUI

struct ToastDisplayModifier<Toast: View>: ViewModifier {
    var alignment: Alignment
    var toastHandler: ToastHandler
    var toastMaker: (ToastHandler) -> Toast
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                toastMaker(toastHandler)
            }
            .environment(\.displayToast, toastHandler.queueMessage(_:))
    }
}

extension View {
    func displayToast<Toast: View> (
        on alignment: Alignment,
        handledBy toastHandler: ToastHandler,
        toastMaker: @escaping (ToastHandler) -> Toast
    ) -> some View {
        self.modifier(
            ToastDisplayModifier(
                alignment: alignment,
                toastHandler: toastHandler,
                toastMaker: toastMaker
            )
        )
    }
}
