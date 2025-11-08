//
//  GetTasks.swift
//  YourQuickToDo
//
//  Created by User on 15/09/25.
//

import Foundation
import RealmSwift

// MARK: - API Service Protocols
protocol AddTaskProtocol {
    func addTask(_ task: TodoTask, completion: @escaping (Result<TodoTask, Error>) -> Void)
}

protocol GetTasksProtocol {
    func getAllTask(completion: @escaping (Result<[TodoTask], Error>) -> Void)
    func getTaskByID(_ id: ObjectId, completion: @escaping (Result<TodoTask?, Error>) -> Void)
}

// MARK: - Mock Service Implementation
class GetMockTasksServices: GetTasksProtocol {
    func getAllTask(completion: @escaping (Result<[TodoTask], Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            // Create mock TodoTask objects with Taskdescription
            let mockTasks = [
                TodoTask(value: [
                    "title": "Buy groceries",
                    "Taskdescription": "Milk, eggs, bread, fruits and vegetables for the week",
                    "isCompleted": false
                ]),
                TodoTask(value: [
                    "title": "Finish project report",
                    "Taskdescription": "Complete the quarterly report for management review by Friday",
                    "isCompleted": true
                ]),
                TodoTask(value: [
                    "title": "Call mom",
                    "Taskdescription": "Discuss weekend plans and check how she's doing",
                    "isCompleted": false
                ]),
                TodoTask(value: [
                    "title": "Gym workout",
                    "Taskdescription": "Chest and triceps day - focus on bench press and tricep extensions",
                    "isCompleted": false
                ]),
                TodoTask(value: [
                    "title": "Read book",
                    "Taskdescription": "Finish chapter 5 of 'SwiftUI Pro - Advanced Development Techniques'",
                    "isCompleted": true
                ])
            ]
            completion(.success(mockTasks))
        }
    }
    
    func getTaskByID(_ id: ObjectId, completion: @escaping (Result<TodoTask?, Error>) -> Void) {
        getAllTask { result in
            switch result {
            case .success(let tasks):
                let task = tasks.first { $0.id == id }
                completion(.success(task))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Real API Service Implementation
class GetTasksServices: GetTasksProtocol {
    func getAllTask(completion: @escaping (Result<[TodoTask], Error>) -> Void) {
        // This would be your actual API call
        // For now, return empty array
        completion(.success([]))
    }
    
    func getTaskByID(_ id: ObjectId, completion: @escaping (Result<TodoTask?, Error>) -> Void) {
        // This would be your actual API call
        completion(.success(nil))
    }
}

// MARK: - Add Task Service Implementation
class AddTaskService: AddTaskProtocol {
    func addTask(_ task: TodoTask, completion: @escaping (Result<TodoTask, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            // Simulate API call to add task
            // In real app, this would send task to your backend
            completion(.success(task))
        }
    }
}
