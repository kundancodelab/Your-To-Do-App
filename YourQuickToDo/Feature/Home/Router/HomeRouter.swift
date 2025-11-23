//
//  HomeRouter.swift
//  YourQuickToDo
//
//  Home Feature Navigation Flow
//

import UIKit

// MARK: - Home Flow Destinations

/// Defines all possible navigation destinations within the Home feature
enum HomeFlow: NavigationDestination {
    case addTask
    case editTask(TodoTask)
    case taskDetail(TodoTask)
    
    // MARK: - NavigationDestination Conformance
    
    var title: String {
        switch self {
        case .addTask:
            return "Add New Task"
        case .editTask:
            return "Edit Task"
        case .taskDetail:
            return "Task Details"
        }
    }
    
    func createViewController() -> UIViewController {
        switch self {
        case .addTask:
            return createAddTaskViewController(editingTask: nil)
            
        case .editTask(let task):
            return createAddTaskViewController(editingTask: task)
            
        case .taskDetail(let task):
            return createTaskDetailViewController(task: task)
        }
    }
    
    // MARK: - Private Factory Methods
    
    private func createAddTaskViewController(editingTask: TodoTask?) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addTaskVC = storyboard.instantiateViewController(withIdentifier: "AddNewTaskVC") as? AddNewTaskVC else {
            fatalError("Could not instantiate AddNewTaskVC from storyboard")
        }
        
        // Inject dependencies
        addTaskVC.taskViewModel = TaskViewModel()
        addTaskVC.editingTask = editingTask
        
        return addTaskVC
    }
    
    private func createTaskDetailViewController(task: TodoTask) -> UIViewController {
        // TODO: Create TaskDetailVC when needed
        // For now, return AddNewTaskVC in edit mode
        return createAddTaskViewController(editingTask: task)
    }
}

// MARK: - Hashable Conformance (for tracking in navigation stack)

extension HomeFlow: Hashable {
    static func == (lhs: HomeFlow, rhs: HomeFlow) -> Bool {
        switch (lhs, rhs) {
        case (.addTask, .addTask):
            return true
        case (.editTask(let lhsTask), .editTask(let rhsTask)):
            return lhsTask.id == rhsTask.id
        case (.taskDetail(let lhsTask), .taskDetail(let rhsTask)):
            return lhsTask.id == rhsTask.id
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .addTask:
            hasher.combine("addTask")
        case .editTask(let task):
            hasher.combine("editTask")
            hasher.combine(task.id)
        case .taskDetail(let task):
            hasher.combine("taskDetail")
            hasher.combine(task.id)
        }
    }
}

// MARK: - Type Alias

/// Type alias for cleaner usage
typealias HomeRouter = Router<HomeFlow>
