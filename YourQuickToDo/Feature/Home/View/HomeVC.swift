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
    /// Empty State
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No tasks yet"
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // MARK: - Router
    var router: HomeRouter?
    
    // MARK: - ViewModel
    private let taskViewModel = TaskViewModel()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.Colors.background
        taskCountLabel.textColor = AppTheme.Colors.textSecondary
        taskCountLabel.font = AppTheme.Fonts.headline()
        setupUI()
        setupTableView()
        setUpDataBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskCountLabel.textColor = AppTheme.Colors.textSecondary // Ensure color is set
        taskViewModel.loadTodaysTasks() // Load only today's tasks for HomeVC
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
    private func setupUI(){
        view.addSubview(emptyStateLabel)
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    private func setUpDataBinding() {
        taskViewModel.onTasksUpdated = { [weak self] in
            print(" HomeVC: onTasksUpdated callback triggered - Reloading table view")
            self?.tableView.reloadData()
            
            // Update task count label with meaningful messages
            guard let tasks = self?.taskViewModel.allTasks else { return }
            
            let totalTasks = tasks.count
            let completedTasks = tasks.filter { $0.isCompleted }.count
            let remainingTasks = totalTasks - completedTasks
            
            self?.emptyStateLabel.isHidden = totalTasks != 0
            self?.tableView.isHidden = totalTasks == 0
            
            if totalTasks == 0 {
                self?.taskCountLabel.text = "No tasks for today"
            } else if completedTasks == 0 {
                // No tasks completed yet
                self?.taskCountLabel.text = "You have \(totalTasks) \n \(totalTasks == 1 ? "task" : "tasks")"
            } else if remainingTasks == 0 {
                // All tasks completed
                self?.taskCountLabel.text = "You have completed \n all tasks! Congrats 🎉"
            } else {
                // Some tasks completed
                self?.taskCountLabel.text = "You have completed \(completedTasks) \n \(completedTasks == 1 ? "task" : "tasks"), \(remainingTasks) left"
            }
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
        // Use router if available, otherwise fallback to direct presentation
        if let router = router {
            router.present(.addTask, modalPresentationStyle: .automatic)
        } else {
            let addTaskViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewTaskVC") as! AddNewTaskVC
            addTaskViewController.modalPresentationStyle = .automatic
            addTaskViewController.taskViewModel = taskViewModel
            present(addTaskViewController, animated: true)
        }
    }
    
    private func navigateToEditTaskController(task: TodoTask) {
        // Use router if available, otherwise fallback to direct presentation
        if let router = router {
            router.present(.editTask(task), modalPresentationStyle: .automatic)
        } else {
            let addTaskViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewTaskVC") as! AddNewTaskVC
            addTaskViewController.modalPresentationStyle = .automatic
            addTaskViewController.taskViewModel = taskViewModel
            addTaskViewController.editingTask = task
            present(addTaskViewController, animated: true)
        }
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
            guard let self = self else { return }
            print("Mark complete button tapped for task: \(task.title)")
            cell.animateWithFadeAndAction {
                let wasCompleted = task.isCompleted
                self.taskViewModel.toggleTaskCompletion(task)
                
                // Show toast with appropriate message
                if wasCompleted {
                    // Task was marked as incomplete
                    self.showToast(
                        message: "🔄 Task marked as incomplete!",
                        duration: 1.5,
                        color: AppTheme.Colors.textSecondary.withAlphaComponent(0.9),
                        isTop: false
                    )
                } else {
                    // Task was marked as complete
                    self.showToast(
                        message: "🎉 Great job! Task completed!",
                        duration: 1.5,
                        color: AppTheme.Colors.primary.withAlphaComponent(0.9),
                        isTop: false
                    )
                }
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
        completeAction.backgroundColor = AppTheme.Colors.secondary
        
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
