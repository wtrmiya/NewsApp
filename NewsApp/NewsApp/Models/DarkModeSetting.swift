//
//  DarkModeSetting.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/07/09.
//

import Foundation

enum DarkModeSetting: Int, CaseIterable, CustomStringConvertible {
    case followDeviceSetting = 0
    case lightModeAlways
    case darkModeAlways
    
    var description: String {
        switch self {
        case .followDeviceSetting:
            return "端末の設定に沿う"
        case .lightModeAlways:
            return "常にライトモードを使用する"
        case .darkModeAlways:
            return "常にダークモードを使用する"
        }
    }
}
