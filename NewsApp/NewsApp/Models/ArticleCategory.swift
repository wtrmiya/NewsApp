//
//  ArticleCategory.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/17.
//

import Foundation

enum ArticleCategory: String, CaseIterable, Hashable {
    case general
    case business
    case technology
    case entertainment
    case sports
    case health
    case science
}

extension ArticleCategory {
    var description: String {
        switch self {
        case .general:
            return "総合"
        case .business:
            return "ビジネス"
        case .technology:
            return "テクノロジ"
        case .entertainment:
            return "エンタメ"
        case .sports:
            return "スポーツ"
        case .health:
            return "健康"
        case .science:
            return "科学"
        }
    }
}
