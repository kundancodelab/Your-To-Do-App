//
//  Category.swift
//  YourQuickToDo
//
//  Created by User on 08/11/25.
//

import Foundation
import RealmSwift
class Category : Object {
    @Persisted var name:String = ""
    let TodoTasks = List<TodoTask>()
}
