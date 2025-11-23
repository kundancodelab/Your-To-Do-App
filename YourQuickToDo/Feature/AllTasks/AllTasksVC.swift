//
//  AllTasksVC.swift
//  YourQuickToDo
//
//  Displays all tasks (completed + pending)
//

import UIKit

class AllTasksVC: AppUtilityBaseClass {
    
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
    
    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["All", "Completed", "Pending"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
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
    
    // MARK: - Properties
    
    private let taskViewModel = TaskViewModel()
    private var filteredTasks: [TodoTask] = []
    
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
        title = "All Tasks"
        view.backgroundColor = .systemBackground
        
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        taskViewModel.onTasksUpdated = { [weak self] in
            self?.applyFilter()
        }
        
        taskViewModel.onLoadingStateChanged = { [weak self] isLoading in
            if !isLoading {
                self?.applyFilter()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func filterChanged() {
        applyFilter()
    }
    
    private func applyFilter() {
        guard let allTasks = taskViewModel.allTasks else {
            filteredTasks = []
            updateEmptyState()
            tableView.reloadData()
            return
        }
        
        switch segmentedControl.selectedSegmentIndex {
        case 0: // All
            filteredTasks = Array(allTasks)
        case 1: // Completed
            filteredTasks = allTasks.filter { $0.isCompleted }
        case 2: // Pending
            filteredTasks = allTasks.filter { !$0.isCompleted }
        default:
            filteredTasks = Array(allTasks)
        }
        
        updateEmptyState()
        tableView.reloadData()
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !filteredTasks.isEmpty
    }
    
    // MARK: - Helper Methods
    
    private func isTaskCreatedToday(_ task: TodoTask) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(task.createdAt)
    }
}

// MARK: - UITableView Delegate & DataSource

extension AllTasksVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        cell.selectionStyle = .none
        
        let task = filteredTasks[indexPath.row]
        cell.configureCell(with: task)
        
        // Mark complete action
        cell.markCompleteButtonTapped = { [weak self] in
            guard let self = self else { return }
            let wasCompleted = task.isCompleted
            self.taskViewModel.toggleTaskCompletion(task)
            
            // Show toast with appropriate message
            if wasCompleted {
                self.showToast(
                    message: "🔄 Task marked as incomplete!",
                    duration: 1.5,
                    color: AppTheme.Colors.textSecondary.withAlphaComponent(0.9),
                    isTop: false
                )
            } else {
                self.showToast(
                    message: "🎉 Great job! Task completed!",
                    duration: 1.5,
                    color: AppTheme.Colors.primary.withAlphaComponent(0.9),
                    isTop: false
                )
            }
        }
        
        // Edit button: Only show for tasks created today
        let canEdit = isTaskCreatedToday(task)
        cell.editButton?.isHidden = !canEdit
        
        // Delete button: Always visible
        cell.deleteButton?.isHidden = false
        
        // Edit action (if visible)
        if canEdit {
            cell.editButtonTapped = { [weak self] in
                self?.navigateToEditTask(task)
            }
        }
        
        // Delete action (always available)
        cell.deleteButtonTapped = { [weak self] in
            self?.showDeleteConfirmation(for: task)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    private func navigateToEditTask(_ task: TodoTask) {
        let addTaskVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewTaskVC") as! AddNewTaskVC
        addTaskVC.modalPresentationStyle = .automatic
        addTaskVC.taskViewModel = taskViewModel
        addTaskVC.editingTask = task
        present(addTaskVC, animated: true)
    }
    
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
