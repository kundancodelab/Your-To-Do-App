//
//  HomeVC.swift
//  YourQuickToDo
//

import UIKit

class HomeVC: UIViewController {
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
    @IBAction func didTapAddNewTaskBtn() {
        let addTaskViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewTaskVC") as! AddNewTaskVC
        addTaskViewController.modalPresentationStyle = .automatic
        addTaskViewController.taskViewModel = taskViewModel
        present(addTaskViewController, animated: true)
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
            self?.tableView.reloadData()
        }
        
        taskViewModel.onLoadingStateChanged = { [weak self] isLoading in
            if isLoading {
                print("Loading tasks...")
            } else {
                print("Tasks loaded")
            }
        }
        
        taskViewModel.onErrorStateChanged = { [weak self] isError, message in
            if isError {
                self?.showErrorAlert(message: message)
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
        
        if let tasks = taskViewModel.allTasks, indexPath.row < tasks.count {
            let task = tasks[indexPath.row]
            cell.configureCell(with: task)
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
