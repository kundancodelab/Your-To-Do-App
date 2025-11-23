//
//  PendingTasksVC.swift
//  YourQuickToDo
//
//  Displays only pending (incomplete) tasks
//

import UIKit

class PendingTasksVC: AppUtilityBaseClass {
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .systemBackground
        table.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "🎉 No pending tasks!\nYou're all caught up!"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var taskCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 pending tasks"
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    
    private let taskViewModel = TaskViewModel()
    private var pendingTasks: [TodoTask] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskViewModel.getAllTasks()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Pending Tasks"
        view.backgroundColor = .systemBackground
        
        view.addSubview(taskCountLabel)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            taskCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            taskCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            taskCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: taskCountLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        taskViewModel.onTasksUpdated = { [weak self] in
            self?.loadPendingTasks()
        }
        
        taskViewModel.onLoadingStateChanged = { [weak self] isLoading in
            if !isLoading {
                self?.loadPendingTasks()
            }
        }
    }
    
    // MARK: - Data Loading
    
    private func loadPendingTasks() {
        guard let allTasks = taskViewModel.allTasks else {
            pendingTasks = []
            updateUI()
            return
        }
        
        pendingTasks = allTasks.filter { !$0.isCompleted }
        updateUI()
    }
    
    private func updateUI() {
        let count = pendingTasks.count
        taskCountLabel.text = "\(count) pending task\(count == 1 ? "" : "s")"
        emptyStateLabel.isHidden = count > 0
        tableView.reloadData()
    }
}

// MARK: - UITableView Delegate & DataSource

extension PendingTasksVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        cell.selectionStyle = .none
        
        let task = pendingTasks[indexPath.row]
        cell.configureCell(with: task)
        
        // Mark complete action
        cell.markCompleteButtonTapped = { [weak self] in
            cell.animateWithFadeAndAction {
                self?.taskViewModel.toggleTaskCompletion(task)
            }
        }
        
        // Disable edit and delete for read-only view
        cell.editButton.isHidden = true
        cell.deleteButton.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Swipe action for quick complete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = pendingTasks[indexPath.row]
        
        let completeAction = UIContextualAction(style: .normal, title: "Complete") { [weak self] (_, _, completion) in
            self?.taskViewModel.toggleTaskCompletion(task)
            completion(true)
        }
        completeAction.backgroundColor = AppTheme.Colors.secondary
        completeAction.image = UIImage(systemName: "checkmark.circle.fill")
        
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
}
