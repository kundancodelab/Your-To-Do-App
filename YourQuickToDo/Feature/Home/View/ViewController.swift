//
//  ViewController.swift
//  YourQuickToDo
//
//  Created by User on 14/09/25.
//

import UIKit

class ViewController: UIViewController {
    /// Tableview
    @IBOutlet weak var tableView:UITableView! {
        didSet {
            tableView.layer.cornerRadius = 16
            tableView.clipsToBounds = true
        }
    }
    
    /// Add task button
    @IBOutlet weak var addTaskButton:UIButton! {
        didSet {
            addTaskButton.layer.cornerRadius = 16
            addTaskButton.clipsToBounds = true
        }
    }
    
    /// Dependecny injection
    let  taskViewModel:TaskViewModel = TaskViewModel(getTasksServices: GetMockTasksServices())
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupTableView()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAlltasks()
       
    }
    
    // MARK: Add new task action
    @IBAction func didTapAddNewTaskBtn() {
        let addTaskViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewTaskVC") as! AddNewTaskVC
        addTaskViewController.modalPresentationStyle = .automatic
        present(addTaskViewController, animated: true)
    }

// MARK: Setup TableView
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
        
    }
    
    // MARK: Setup Bindings
       private func setupBindings() {
           taskViewModel.onTasksUpdated = { [weak self] in
               self?.tableView.reloadData()
           }
       }
    // MARK: Fetch all tasks.
    private func fetchAlltasks() {
        taskViewModel.getAllTasks()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskViewModel.allTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        let task = taskViewModel.allTasks[indexPath.row]
        cell.configureCell(with: task)
        cell.selectionStyle = .none
        return cell
    }
}
