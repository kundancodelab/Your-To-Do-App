//
//  ProfileVC.swift
//  YourQuickToDo
//
//  User Profile and Settings
//

import UIKit
import UserNotifications

class ProfileVC: AppUtilityBaseClass {
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .systemGroupedBackground
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Properties
    
    private var router = RouterManager.profileRouter
    private let taskViewModel = TaskViewModel()
    
    private enum Section: Int, CaseIterable {
        case notifications
        case data
        case about
        
        var title: String {
            switch self {
            case .notifications: return "Notifications"
            case .data: return "Data Management"
            case .about: return "About"
            }
        }
    }
    
    private enum NotificationRow: Int, CaseIterable {
        case enable
       
        
        var title: String {
            switch self {
            case .enable: return "Enable Notifications"
           
            }
        }
    }
    
    private enum DataRow: Int, CaseIterable {
        case clearAll
        
        var title: String {
            switch self {
            case .clearAll: return "Clear All Tasks"
            }
        }
    }
    
    private enum AboutRow: Int, CaseIterable {
        case version
        case about
        
        var title: String {
            switch self {
            case .version: return "Version"
            case .about: return "About"
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RouterManager.profileRouter.setNavigationController(self.navigationController!)
        setupUI()
        //setupRouter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Setup
    
    private func setupRouter() {
        // Initialize router with navigation controller
        // This is similar to how @StateObject works in SwiftUI
        if router == nil, let navController = navigationController {
            router = ProfileRouter(navigationController: navController)
            print("✅ ProfileVC: Router initialized with navigation controller")
        }
    }
    
    private func setupUI() {
        title = "Profile"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    private func handleNotificationToggle(_ isOn: Bool, completion: @escaping (Bool) -> Void) {
        if isOn {
            NotificationManager.shared.requestPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.showToast(message: "Notifications enabled", duration: 2.0, color: AppTheme.Colors.secondary.withAlphaComponent(0.8), isTop: false)
                    } else {
                        self.showCustomAlert(title: "Permission Denied", message: "Please enable notifications in Settings", viewController: self)
                    }
                    completion(granted)
                }
            }
        } else {
            completion(true)
        }
    }
    
    private func handleClearAllTasks() {
        let alert = UIAlertController(
            title: "Clear All Tasks",
            message: "Are you sure you want to delete all tasks? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            self?.taskViewModel.clearAllTasks()
            self?.showToast(message: "All tasks cleared", duration: 2.0, color: .systemRed.withAlphaComponent(0.8), isTop: false)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UITableView Delegate & DataSource

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .notifications:
            return NotificationRow.allCases.count
        case .data:
            return DataRow.allCases.count
        case .about:
            return AboutRow.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        
        guard let sectionType = Section(rawValue: indexPath.section) else { return cell }
        
        switch sectionType {
        case .notifications:
            configureNotificationCell(cell, at: indexPath)
        case .data:
            configureDataCell(cell, at: indexPath)
        case .about:
            configureAboutCell(cell, at: indexPath)
        }
        
        return cell
    }
    
    private func configureNotificationCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        guard let row = NotificationRow(rawValue: indexPath.row) else { return }
        
        cell.textLabel?.text = row.title
        
        switch row {
        case .enable:
            let switchControl = UISwitch()
            switchControl.addTarget(self, action: #selector(notificationSwitchChanged(_:)), for: .valueChanged)
            
            // Check current notification status
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    switchControl.isOn = settings.authorizationStatus == .authorized
                }
            }
            
            cell.accessoryView = switchControl
            cell.selectionStyle = .none
            
       
        }
    }
    
    private func configureDataCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        guard let row = DataRow(rawValue: indexPath.row) else { return }
        
        cell.textLabel?.text = row.title
        cell.textLabel?.textColor = .systemRed
    }
    
    private func configureAboutCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        guard let row = AboutRow(rawValue: indexPath.row) else { return }
        
        cell.textLabel?.text = row.title
        
        switch row {
        case .version:
            cell.detailTextLabel?.text = "1.0.0"
            cell.selectionStyle = .none
        case .about:
            cell.accessoryType = .disclosureIndicator
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let sectionType = Section(rawValue: indexPath.section) else { return }
        
        switch sectionType {
        case .notifications:
//            if let row = NotificationRow(rawValue: indexPath.row), row == .settings {
//                router?.navigate(to: .notificationSettings)
//            }
            print("Notifications got clicked.")
        case .data:
            if let row = DataRow(rawValue: indexPath.row), row == .clearAll {
                handleClearAllTasks()
            }
        case .about:
            if let row = AboutRow(rawValue: indexPath.row), row == .about {
                router.navigate(to: .about)  // Use Router pattern!
            }
        }
    }
    
    @objc private func notificationSwitchChanged(_ sender: UISwitch) {
        handleNotificationToggle(sender.isOn) { granted in
            sender.isOn = granted
        }
    }
}
