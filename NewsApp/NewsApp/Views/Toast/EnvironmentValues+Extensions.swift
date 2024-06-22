//
//  EnvironmentValues+Extensions.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/22.
//

import SwiftUI

typealias DisplayToastAction = @MainActor (String) -> Void

struct DisplayToastKey: EnvironmentKey {
    static var defaultValue: DisplayToastAction?
}

extension EnvironmentValues {
    var displayToast: DisplayToastAction? {
        get { self[DisplayToastKey.self] }
        set { self[DisplayToastKey.self] = newValue }
    }
}
