//
//  Item.swift
//  realmTest
//
//  Created by Марк Голубев on 15.02.2023.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    @Persisted var dateCreated: Date = .now
    @Persisted var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
