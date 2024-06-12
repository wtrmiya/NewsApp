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
            body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, ",
            effectiveDate: Date(),
            createdAt: Date()
        )
    }
}
