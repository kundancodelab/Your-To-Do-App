//
//  TaskViewModel.swift
//  YourQuickToDo
//
//  Created by User on 15/09/25.
//

import Foundation

class TaskViewModel {
    var allTasks: [Task] = [] {
          didSet {
              onTasksUpdated?() // Notify when tasks change or  fetched.
          }
      }
    var isLoading: Bool = false
    var isError: Bool = false
    var errorMessage: String = ""
    
    /// Callback for when tasks are updated
       var onTasksUpdated: (() -> Void)?
    /// Dependency injections
    let getTasksServices: getTasksProtocol
    init( getTasksServices: getTasksProtocol){
        self.getTasksServices = getTasksServices
    }
    
    
    func getAllTasks(){
        isLoading = true
        getTasksServices.getAllTask { [weak self] result in
            self?.isLoading = false
            DispatchQueue.main.async {
                switch result {
                case .success(let tasks):
                    print(tasks)
                    self?.allTasks = tasks
                case .failure(let error):
                    print(error)
                    self?.isError = true
                    self?.errorMessage = error.localizedDescription
                }
            }
            
        }
    }
}
