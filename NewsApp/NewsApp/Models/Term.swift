//
//  Term.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/13.
//

import Foundation
import FirebaseFirestore

struct Term: Decodable {
    let title: String
    let body: String
    let effectiveDate: Date
    let createdAt: Date
}

extension Term {
    var formattedEffectiveDateDescription: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        return dateFormatter.string(from: effectiveDate)
    }
    
    var escapeRemovedBody: String {
        return body.replacing(/\\n/, with: "\n")
    }
    
    static func fromSnapshot(snapshot: QueryDocumentSnapshot) -> Term? {
        let dictionary = snapshot.data()
        guard let title = dictionary["title"] as? String,
              let body = dictionary["body"] as? String,
              let effectiveDate = (dictionary["effectiveDate"] as? Timestamp)?.dateValue(),
              let createdAt = (dictionary["createdAt"] as? Timestamp)?.dateValue()
        else {
            return nil
        }

        return Term(
            title: title,
            body: body,
            effectiveDate: effectiveDate,
            createdAt: createdAt
        )
    }
    
    static var emptyTerm: Term {
        return Term(
            title: "NewsApp利用規約",
            body: "読み込み中です",
            effectiveDate: Date(),
            createdAt: Date()
        )
    }
}
