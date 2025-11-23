//
//  TaskRepository.swift
//  YourQuickToDo
//
//  Created by User on 08/11/25.
//


import Foundation
import RealmSwift

protocol TaskRepositoryProtocol {
    // MARK: - CRUD Operations
    func getAllTasks() -> Results<TodoTask>?
    func getTask(by id: ObjectId) -> TodoTask?
    func addTask(_ task: TodoTask) -> Bool
    func updateTask(_ task: TodoTask, updates: [String: Any]) -> Bool
    func deleteTask(_ task: TodoTask) -> Bool
    func toggleTaskCompletion(_ task: TodoTask) -> Bool
    
    // MARK: - Filtering
    func getCompletedTasks() -> Results<TodoTask>?
    func getPendingTasks() -> Results<TodoTask>?
    func searchTasks(query: String) -> Results<TodoTask>?
    func getTodaysTasks() -> Results<TodoTask>?
    
    // MARK: - Bulk Operations
    func addTasks(_ tasks: [TodoTask]) -> Bool
    func deleteAllTasks() -> Bool
}


class TaskRepository: TaskRepositoryProtocol {
    private var realm: Realm?
    
    init() {
        setupRealm()
    }
    
    private func setupRealm() {
        do {
            realm = try Realm()
            print("✅ Realm database path: \(realm?.configuration.fileURL?.path ?? "Unknown")")
        } catch {
            print("❌ Realm initialization failed: \(error)")
            realm = nil
        }
    }
    
    // MARK: - CRUD Operations
    
    func getAllTasks() -> Results<TodoTask>? {
        return realm?.objects(TodoTask.self).sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    func getTask(by id: ObjectId) -> TodoTask? {
        return realm?.object(ofType: TodoTask.self, forPrimaryKey: id)
    }
    
    func addTask(_ task: TodoTask) -> Bool {
        guard let realm = realm else { return false }
        
        do {
            try realm.write {
                realm.add(task)
            }
            return true
        } catch {
            print("❌ Error adding task: \(error)")
            return false
        }
    }
    
    func updateTask(_ task: TodoTask, updates: [String: Any]) -> Bool {
        guard let realm = realm else { return false }
        
        do {
            try realm.write {
                task.setValuesForKeys(updates)
                task.updatedAt = Date()
            }
            return true
        } catch {
            print("❌ Error updating task: \(error)")
            return false
        }
    }
    
    func deleteTask(_ task: TodoTask) -> Bool {
        guard let realm = realm else { return false }
        
        do {
            try realm.write {
                realm.delete(task)
            }
            return true
        } catch {
            print("❌ Error deleting task: \(error)")
            return false
        }
    }
    
    func toggleTaskCompletion(_ task: TodoTask) -> Bool {
        guard let realm = realm else { return false }
        
        do {
            try realm.write {
                task.isCompleted.toggle()
                task.updatedAt = Date()
            }
            return true
        } catch {
            print("❌ Error toggling task: \(error)")
            return false
        }
    }
    
    // MARK: - Filtering
    
    func getCompletedTasks() -> Results<TodoTask>? {
        return realm?.objects(TodoTask.self)
            .filter("isCompleted == true")
            .sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    func getPendingTasks() -> Results<TodoTask>? {
        return realm?.objects(TodoTask.self)
            .filter("isCompleted == false")
            .sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    func searchTasks(query: String) -> Results<TodoTask>? {
        return realm?.objects(TodoTask.self)
            .filter("title CONTAINS[c] %@", query)
            .sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    func getTodaysTasks() -> Results<TodoTask>? {
        // Use device's current calendar which respects user's timezone
        let calendar = Calendar.current
        let now = Date() // Current moment in time (timezone-agnostic)
        
        // Get start and end of "today" in user's local timezone
        let startOfToday = calendar.startOfDay(for: now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        
        // Debug: Print timezone info
        print("🌍 Timezone: \(TimeZone.current.identifier), Offset: \(TimeZone.current.secondsFromGMT() / 3600)h")
        print("📅 Today's range: \(startOfToday) to \(endOfToday)")
        
        // Filter tasks created between start and end of today (in user's timezone)
        return realm?.objects(TodoTask.self)
            .filter("createdAt >= %@ AND createdAt < %@", startOfToday, endOfToday)
            .sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    // MARK: - Bulk Operations
    
    func addTasks(_ tasks: [TodoTask]) -> Bool {
        guard let realm = realm else { return false }
        
        do {
            try realm.write {
                realm.add(tasks)
            }
            return true
        } catch {
            print("❌ Error adding multiple tasks: \(error)")
            return false
        }
    }
    
    func deleteAllTasks() -> Bool {
        guard let realm = realm else { return false }
        
        do {
            try realm.write {
                realm.delete(realm.objects(TodoTask.self))
            }
            return true
        } catch {
            print("❌ Error deleting all tasks: \(error)")
            return false
        }
    }
}

class MockTaskRepository: TaskRepositoryProtocol {
    // In-memory storage only - NO Realm
    private var mockTasks: [TodoTask] = []
    
    func getAllTasks() -> Results<TodoTask>? {
        // Return nil since we're not using Realm
        // Or create a temporary Realm in-memory if you need Results
        return nil
    }
    
    func getTask(by id: ObjectId) -> TodoTask? {
        return mockTasks.first { $0.id == id }
    }
    
    func addTask(_ task: TodoTask) -> Bool {
        mockTasks.append(task)
        return true
    }
    
    func updateTask(_ task: TodoTask, updates: [String: Any]) -> Bool {
        guard let index = mockTasks.firstIndex(where: { $0.id == task.id }) else { return false }
        
        for (key, value) in updates {
            mockTasks[index].setValue(value, forKey: key)
        }
        return true
    }
    
    func deleteTask(_ task: TodoTask) -> Bool {
        mockTasks.removeAll { $0.id == task.id }
        return true
    }
    
    func toggleTaskCompletion(_ task: TodoTask) -> Bool {
        guard let index = mockTasks.firstIndex(where: { $0.id == task.id }) else { return false }
        mockTasks[index].isCompleted.toggle()
        return true
    }
    
    // For mock repository, return arrays instead of Results
    func getAllTasksArray() -> [TodoTask] {
        return mockTasks
    }
    
    func getCompletedTasks() -> Results<TodoTask>? { return nil }
    func getPendingTasks() -> Results<TodoTask>? { return nil }
    func searchTasks(query: String) -> Results<TodoTask>? { return nil }
    func getTodaysTasks() -> Results<TodoTask>? { return nil }
    func addTasks(_ tasks: [TodoTask]) -> Bool {
        mockTasks.append(contentsOf: tasks)
        return true
    }
    func deleteAllTasks() -> Bool {
        mockTasks.removeAll()
        return true
    }
}
