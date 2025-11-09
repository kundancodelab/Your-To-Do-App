//
//  TaskViewModel.swift
//  YourQuickToDo
//

import Foundation
import RealmSwift

class TaskViewModel {
    // MARK: - Published Properties
    var allTasks: Results<TodoTask>? {
        didSet {
            print("🔄 ViewModel: allTasks updated - \(allTasks?.count ?? 0) tasks")
            onTasksUpdated?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            print("⏳ ViewModel: isLoading = \(isLoading)")
            onLoadingStateChanged?(isLoading)
        }
    }
    
    var isError: Bool = false {
        didSet { onErrorStateChanged?(isError, errorMessage) }
    }
    
    var errorMessage: String = ""
    private var notificationToken: NotificationToken?
    // MARK: - Callbacks
    var onTasksUpdated: (() -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onErrorStateChanged: ((Bool, String) -> Void)?
    
    // MARK: - Dependencies
    private let taskRepository: TaskRepositoryProtocol
    private let apiService: GetTasksProtocol
    private let isUsingMockData: Bool
    // MARK: - Initialization
    init(
        taskRepository: TaskRepositoryProtocol = TaskRepository(),
        apiService: GetTasksProtocol = GetMockTasksServices()
    ) {
        self.taskRepository = taskRepository
        self.apiService = apiService
        isUsingMockData  = true
        setupRealmObserver()
        print("✅ TaskViewModel initialized")
    }
    
    deinit {
           notificationToken?.invalidate()
       }
    // MARK: - Public Methods
    func getAllTasks() {
        isLoading = true
        
        // Load from real Realm database
        loadLocalTasks()
        syncWithRemote()
        
    }
    private func setupRealmObserver() {
           allTasks = taskRepository.getAllTasks()
           
           notificationToken = allTasks?.observe { [weak self] changes in
               print("👀 ViewModel: Realm collection changed")
               self?.onTasksUpdated?()
           }
       }
    
    func addTask(title: String) {
        print("➕ ViewModel: Adding task - \(title)")
        let newTask = TodoTask(title: title)
        
        if taskRepository.addTask(newTask) {
            loadLocalTasks() // Refresh local data
        } else {
            handleError(NSError(domain: "Database Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add task"]))
        }
    }
    
    func addTask(_ task: TodoTask) {
        print("➕ ViewModel: Adding task object - \(task.title)")
        if taskRepository.addTask(task) {
            loadLocalTasks()
        } else {
            handleError(NSError(domain: "Database Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add task"]))
        }
    }
    
    func deleteTask(_ task: TodoTask) {
        print("🗑️ ViewModel: Deleting task - \(task.title)")
        if taskRepository.deleteTask(task) {
            loadLocalTasks()
        } else {
            handleError(NSError(domain: "Database Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to delete task"]))
        }
    }
    
    // MARK: - Update Task Method
    func updateTask(_ task: TodoTask, updates: [String: Any]) -> Bool {
        print("✏️ ViewModel: Updating task - \(task.title)")
        
        if taskRepository.updateTask(task, updates: updates) {
            // No need to manually reload - Realm observer will handle it
            return true
        } else {
            handleError(NSError(domain: "Database Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to update task"]))
            return false
        }
    }
    
    func toggleTaskCompletion(_ task: TodoTask) {
        print("🔘 ViewModel: Toggling task - \(task.title) to \(!task.isCompleted)")
        if !taskRepository.toggleTaskCompletion(task) {
            handleError(NSError(domain: "Database Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to update task"]))
        }
        // No need to reload - Realm Results auto-update
    }
    
    func updateTaskTitle(_ task: TodoTask, newTitle: String) {
        print("✏️ ViewModel: Updating task title - \(task.title) → \(newTitle)")
        let updates = ["title": newTitle]
        
        if !taskRepository.updateTask(task, updates: updates) {
            handleError(NSError(domain: "Database Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to update task"]))
        }
    }
    
    func getCompletedTasks() -> Results<TodoTask>? {
        return taskRepository.getCompletedTasks()
    }
    
    func getPendingTasks() -> Results<TodoTask>? {
        return taskRepository.getPendingTasks()
    }
    
    func searchTasks(query: String) -> Results<TodoTask>? {
        return taskRepository.searchTasks(query: query)
    }
    
    // MARK: - Private Methods
    
    private func loadLocalTasks() {
        print("📂 ViewModel: Loading local tasks from Realm")
        allTasks = taskRepository.getAllTasks()
        
        // Debug: Print what's in Realm
        if let tasks = allTasks {
            print("📊 ViewModel: Realm contains \(tasks.count) tasks")
            for task in tasks.prefix(3) { // Show first 3 tasks
                print("   📝 - '\(task.title)' | Completed: \(task.isCompleted) | Created: \(task.createdAt)")
            }
            if tasks.count > 3 {
                print("   ... and \(tasks.count - 3) more tasks")
            }
        }
        
        isLoading = false
        print("✅ ViewModel: Local tasks loaded")
    }
    
    private func syncWithRemote() {
        print("🌐 ViewModel: Starting remote sync with mock service")
        apiService.getAllTask { [weak self] (result: Result<[TodoTask], Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                print("🌐 ViewModel: Mock service response received")
                self.isLoading = false
                
                switch result {
                case .success(let remoteTasks):
                    print("✅ ViewModel: Mock service returned \(remoteTasks.count) tasks")
                    self.handleRemoteTasks(remoteTasks)
                case .failure(let error):
                    print("❌ ViewModel: Mock service error - \(error)")
                    self.handleError(error)
                }
            }
        }
    }
    
    private func handleRemoteTasks(_ remoteTasks: [TodoTask]) {
        print("🔄 ViewModel: Processing \(remoteTasks.count) remote tasks")
        if isUsingMockData {
               print("💡 Mock mode: Skipping Realm save for remote tasks")
               return // Don't save mock data to Realm!
           }
        var newTasksCount = 0
        for remoteTask in remoteTasks {
            // Check if task already exists locally
            if taskRepository.getTask(by: remoteTask.id) == nil {
                // Add new task from remote
                if taskRepository.addTask(remoteTask) {
                    newTasksCount += 1
                    print("📥 ViewModel: Added new task from remote - '\(remoteTask.title)'")
                }
            } else {
                print("ℹ️ ViewModel: Task already exists - '\(remoteTask.title)'")
            }
        }
        
        print("📥 ViewModel: Added \(newTasksCount) new tasks from remote")
        
        // Refresh local data
        loadLocalTasks()
    }
    
    private func handleError(_ error: Error) {
        print("❌ ViewModel: Error handled - \(error.localizedDescription)")
        isError = true
        errorMessage = error.localizedDescription
        onErrorStateChanged?(true, errorMessage)
    }
    
    func clearError() {
        isError = false
        errorMessage = ""
        onErrorStateChanged?(false, "")
    }
    
    // MARK: - Debug Methods
    
    func clearAllTasks() {
        print("🧹 ViewModel: Clearing ALL tasks from Realm")
        _ = taskRepository.deleteAllTasks()
        loadLocalTasks()
    }
}


extension TaskViewModel {
    private func loadMockTasks() {
        print("🎭 Loading MOCK data (not saving to Realm)")
        apiService.getAllTask { [weak self] (result: Result<[TodoTask], Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let mockTasks):
                    print("🎭 Mock data loaded: \(mockTasks.count) tasks")
                    
                    // TEMPORARY: Just show mock data without saving
                    // This will display but won't persist
                    let temporaryRealm = try! Realm()
                    self.allTasks = temporaryRealm.objects(TodoTask.self).filter("NONE") // Empty results
                    
                    // For demo purposes, we'll just log the mock data
                    for task in mockTasks {
                        print("   🎭 Mock Task: '\(task.title)' - \(task.isCompleted ? "Completed" : "Pending")")
                    }
                    
                    print("💡 Note: Mock data is displayed in logs but NOT saved to Realm")
                    
                case .failure(let error):
                    print("❌ Mock service error: \(error)")
                    self.handleError(error)
                }
            }
        }
    }
}
