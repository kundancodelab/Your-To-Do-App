//
//  HomeVC.swift
//  YourQuickToDo
//

import UIKit

class HomeVC: AppUtilityBaseClass {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.layer.cornerRadius = 16
            tableView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var addTaskButton: UIButton! {
        didSet {
            addTaskButton.layer.cornerRadius = 16
            addTaskButton.clipsToBounds = true
        }
    }
    /// Task count label
    @IBOutlet weak var taskCountLabel: UILabel!
    // MARK: - ViewModel
    private let taskViewModel = TaskViewModel()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskViewModel.getAllTasks()
    }
    
    // MARK: - IBActions
    @IBAction func didTapAddNewTaskBtn(_ sender:UIButton) {
        sender.animateWithFadeAndAction {
            self.navigateToNewTaskController()
        }
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
    }
    
    private func setupBindings() {
        taskViewModel.onTasksUpdated = { [weak self] in
            print("🔄 HomeVC: onTasksUpdated callback triggered - Reloading table view")
            self?.tableView.reloadData()
        }
        
        taskViewModel.onLoadingStateChanged = { [weak self] isLoading in
            if isLoading {
                print(" HomeVC: Loading tasks...")
            } else {
                print(" HomeVC: Tasks loaded")
                self?.taskCountLabel.text = "You have \(self?.taskViewModel.allTasks?.count ?? 0) tasks left !"
            }
        }
        
        taskViewModel.onErrorStateChanged = { [weak self] isError, message in
            if isError {
                print(" HomeVC: Error - \(message)")
                self?.showErrorAlert(message: message)
            }
        }
        
        
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateToNewTaskController(taskId:String = ""){
        let addTaskViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewTaskVC") as! AddNewTaskVC
        addTaskViewController.modalPresentationStyle = .automatic
        addTaskViewController.taskViewModel = taskViewModel
        present(addTaskViewController, animated: true)
    }
    
    private func navigateToEditTaskController(task: TodoTask) {
        let addTaskViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewTaskVC") as! AddNewTaskVC
        addTaskViewController.modalPresentationStyle = .automatic
        addTaskViewController.taskViewModel = taskViewModel
        addTaskViewController.editingTask = task // Pass the task to edit
        present(addTaskViewController, animated: true)
    }
}

// MARK: - UITableView Delegate & DataSource
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskViewModel.allTasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        cell.selectionStyle = .none

        guard let tasks = taskViewModel.allTasks, indexPath.row < tasks.count else {
            return cell
        }
        
        let task = tasks[indexPath.row]
        cell.configureCell(with: task)
        
        /// Edit task action
        cell.editButtonTapped = { [weak self] in
            print("Edit button tapped for task: \(task.title)")
            cell.animateWithFadeAndAction {
                self?.navigateToEditTaskController(task: task)
              
            }
        }
        
        /// Delete task - FIXED: No navigation needed
        cell.deleteButtonTapped = { [weak self] in
            print("Delete button tapped for task: \(task.title)")
            cell.animateWithFadeAndAction {
                self?.showDeleteConfirmation(for: task)
            }
        }
        
        /// Mark complete task - FIXED: No navigation needed
        cell.markCompleteButtonTapped = { [weak self] in
            print("Mark complete button tapped for task: \(task.title)")
            cell.animateWithFadeAndAction {
                self?.taskViewModel.toggleTaskCompletion(task)
                // Realm observer will automatically update the UI
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let tasks = taskViewModel.allTasks, indexPath.row < tasks.count else {
            return nil
        }
        
        let task = tasks[indexPath.row]
        
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.taskViewModel.deleteTask(task)
            completion(true)
        }
        
        // Toggle complete action
        let completeTitle = task.isCompleted ? "Mark Incomplete" : "Mark Complete"
        let completeAction = UIContextualAction(style: .normal, title: completeTitle) { [weak self] (_, _, completion) in
            self?.taskViewModel.toggleTaskCompletion(task)
            completion(true)
        }
        completeAction.backgroundColor = task.isCompleted ? .orange : .systemGreen
        
        return UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
    }
}


extension HomeVC {
    private func showDeleteConfirmation(for task: TodoTask) {
        let alert = UIAlertController(
            title: "Delete Task",
            message: "Are you sure you want to delete '\(task.title)'?",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.taskViewModel.deleteTask(task)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
