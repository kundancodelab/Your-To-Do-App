//
//  Task.swift
//  YourQuickToDo
//
//  Created by User on 15/09/25.
//



import Foundation

struct Task: Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String
    var description: String?
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date?
    
    // Optional: Add custom initializer for convenience
    init(id: UUID = UUID(), title: String, description: String? = nil, isCompleted: Bool = false, createdAt: Date = Date(), updatedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Conform to Equatable for easier testing and comparison
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }
}
