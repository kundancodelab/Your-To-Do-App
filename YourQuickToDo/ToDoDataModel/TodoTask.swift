//
//  Task.swift
//  YourQuickToDo
//
//  Created by User on 08/11/25.
//

import Foundation
import RealmSwift

class TodoTask: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted  var Taskdescription: String
    @Persisted var isCompleted: Bool = false
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
    @Persisted var deadline: Date?
     
    var  parentCategory = LinkingObjects(fromType: Category.self, property:"TodoTasks")
    
    convenience init(title: String, description: String = "", deadline: Date? = nil) {
           self.init()
           self.title = title
           self.Taskdescription = description
           self.deadline = deadline
       }
}
