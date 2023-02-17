//
//  Category.swift
//  realmTest
//
//  Created by Марк Голубев on 15.02.2023.
//

import Foundation
import RealmSwift
import ChameleonFramework

class Category: Object {
    @Persisted var name: String = ""
    @Persisted var color: String = UIColor.randomFlat().hexValue()
    @Persisted var items = List<Item>()
}
