//
//  GetTasks.swift
//  YourQuickToDo
//
//  Created by User on 15/09/25.
//

import Foundation

protocol getTasksProtocol {
    func getAllTask(completion: @escaping (Result<[Task], Error>) -> Void)
    func getTaskByID(_ id: UUID, completion: @escaping (Result<Task?, Error>) -> Void)
}

class GetTasksServices: getTasksProtocol {
    func getAllTask(completion: @escaping (Result<[Task], Error>) -> Void) {
        // This would be your actual API/database call
        // For now, return empty array or implement real logic later
        completion(.success([]))
    }
    
    func getTaskByID(_ id: UUID, completion: @escaping (Result<Task?, Error>) -> Void) {
        // This would be your actual API/database call
        completion(.success(nil))
    }
}

class GetMockTasksServices: getTasksProtocol {
    func getAllTask(completion: @escaping (Result<[Task], Error>) -> Void) {
        // Return mock tasks with 2-second delay to simulate network call
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let mockTasks = [
                Task(
                    title: "Buy groceries",
                    description: "Milk, eggs, bread, fruits these are very important to brings as we workout every day we need to eat lots in order to gain muscle quickly. So that we can build muscle and become strong. And take participate in body building competition.",
                    isCompleted: false,
                    createdAt: Date().addingTimeInterval(-86400), // 1 day ago
                    updatedAt: nil
                ),
                Task(
                    title: "Finish project report",
                    description: "Complete the quarterly report for management",
                    isCompleted: true,
                    createdAt: Date().addingTimeInterval(-172800), // 2 days ago
                    updatedAt: Date().addingTimeInterval(-86400) // 1 day ago
                ),
                Task(
                    title: "Call mom",
                    description: nil,
                    isCompleted: false,
                    createdAt: Date().addingTimeInterval(-43200), // 12 hours ago
                    updatedAt: nil
                ),
                Task(
                    title: "Gym workout",
                    description: "Chest and triceps day",
                    isCompleted: false,
                    createdAt: Date().addingTimeInterval(-108000), // 30 hours ago
                    updatedAt: nil
                ),
                Task(
                    title: "Read book",
                    description: "Finish chapter 5 of 'Swift Programming'",
                    isCompleted: true,
                    createdAt: Date().addingTimeInterval(-259200), // 3 days ago
                    updatedAt: Date().addingTimeInterval(-86400) // 1 day ago
                )
            ]
            completion(.success(mockTasks))
        }
    }
    
    func getTaskByID(_ id: UUID, completion: @escaping (Result<Task?, Error>) -> Void) {
        // Get all tasks and find the one with matching ID
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
