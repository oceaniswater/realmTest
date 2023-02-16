//
//  Category.swift
//  realmTest
//
//  Created by Марк Голубев on 15.02.2023.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted dynamic var name: String = ""
    @Persisted var items = List<Item>()
}
