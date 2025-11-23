//
//  AddNewTaskVC.swift
//  YourQuickToDo
//
//  Created by User on 15/09/25.
//
//

import UIKit
import ObjectiveC

// Associated object keys
private struct AssociatedKeys {
    static var datePicker = "datePicker"
}


class AddNewTaskVC: AppUtilityBaseClass {
    
    @IBOutlet weak var addTaskBGView: UIView!{
        didSet {
            addTaskBGView.layer.cornerRadius = 8
            addTaskBGView.clipsToBounds = true
            addTaskBGView.layer.shadowColor = UIColor.lightGray.cgColor
            addTaskBGView.layer.shadowOffset = CGSize(width: 0, height: 2)
            addTaskBGView.layer.shadowOpacity = 0.5
            addTaskBGView.layer.shadowRadius = 4
        }
    }
    
    @IBOutlet weak var tfTaskTitle: UITextField! {
        didSet{
            tfTaskTitle.layer.borderWidth = 1
            tfTaskTitle.layer.borderColor = UIColor.systemGray.cgColor
            tfTaskTitle.layer.cornerRadius = 8
            tfTaskTitle.setLeftPaddingPoints(10)
        }
    }
    
    @IBOutlet weak var tfTaskDescription: UITextField! {
        didSet{
            tfTaskDescription.layer.borderWidth = 1
            tfTaskDescription.layer.borderColor = UIColor.systemGray.cgColor
            tfTaskDescription.layer.cornerRadius = 8
            tfTaskDescription.setLeftPaddingPoints(10)
        }
    }
    
    @IBOutlet weak var tfTaskDeadline: UITextField! {
        didSet{
            tfTaskDeadline.layer.borderWidth = 1
            tfTaskDeadline.layer.borderColor = UIColor.systemGray.cgColor
            tfTaskDeadline.layer.cornerRadius = 8
            tfTaskDeadline.setLeftPaddingPoints(10)
        }
    }
    
    @IBOutlet weak var btnAddTask: UIButton!{
        didSet {
            btnAddTask.layer.cornerRadius = 12
        }
    }
    
    // Calendar button for date selection
    private let calendarButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "calendar", withConfiguration: config), for: .normal)
        button.tintColor = AppTheme.Colors.primary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Dependencies
    var taskViewModel: TaskViewModel!
    
    var editingTask: TodoTask?
    
    // Store selected deadline
    private var selectedDeadline: Date?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupCalendarButton()
        setupForEditMode()
    }
    
    private func setupTextFields() {
        tfTaskTitle.delegate = self
        tfTaskDescription.delegate = self
        tfTaskDeadline.delegate = self
        
        // Add toolbar with Done button
        addDoneButtonToTextFields()
        
        // Set placeholder for deadline
        tfTaskDeadline.placeholder = "Select deadline (optional)"
    }
    
    private func setupForEditMode() {
            if let task = editingTask {
                // Populate fields with existing task data
                tfTaskTitle.text = task.title
                tfTaskDescription.text = task.Taskdescription
                
                // Format and set deadline if exists
                if let deadline = task.deadline {
                    selectedDeadline = deadline
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .short
                    tfTaskDeadline.text = formatter.string(from: deadline)
                }
                
                // Update button title for edit mode
                btnAddTask.setTitle("Update Task", for: .normal)
            } else {
                btnAddTask.setTitle("Add Task", for: .normal)
            }
        }
    
    private func setupCalendarButton() {
        // Add calendar button to deadline text field
        tfTaskDeadline.addSubview(calendarButton)
        
        NSLayoutConstraint.activate([
            calendarButton.trailingAnchor.constraint(equalTo: tfTaskDeadline.trailingAnchor, constant: -10),
            calendarButton.centerYAnchor.constraint(equalTo: tfTaskDeadline.centerYAnchor),
            calendarButton.widthAnchor.constraint(equalToConstant: 30),
            calendarButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        calendarButton.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
    }
    
    @objc private func calendarButtonTapped() {
        presentDatePickerBottomSheet()
    }
    
    private func presentDatePickerBottomSheet() {
        let bottomSheetVC = UIViewController()
        bottomSheetVC.modalPresentationStyle = .pageSheet
        
        if let sheet = bottomSheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        bottomSheetVC.view.backgroundColor = .systemBackground
        
        // Date picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        if let deadline = selectedDeadline {
            datePicker.date = deadline
        }
        
        bottomSheetVC.view.addSubview(datePicker)
        
        // Done button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        doneButton.backgroundColor = AppTheme.Colors.primary
        doneButton.tintColor = .white
        doneButton.layer.cornerRadius = 12
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(confirmDateSelection(_:)), for: .touchUpInside)
        
        bottomSheetVC.view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: bottomSheetVC.view.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: bottomSheetVC.view.centerYAnchor, constant: -40),
            datePicker.leadingAnchor.constraint(equalTo: bottomSheetVC.view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: bottomSheetVC.view.trailingAnchor, constant: -20),
            
            doneButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 30),
            doneButton.leadingAnchor.constraint(equalTo: bottomSheetVC.view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: bottomSheetVC.view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        objc_setAssociatedObject(bottomSheetVC, &AssociatedKeys.datePicker, datePicker, .OBJC_ASSOCIATION_RETAIN)
        
        present(bottomSheetVC, animated: true)
    }
    
    @objc private func confirmDateSelection(_ sender: UIButton) {
        // Get the date picker from the presented view controller
        if let presentedVC = presentedViewController,
           let datePicker = objc_getAssociatedObject(presentedVC, &AssociatedKeys.datePicker) as? UIDatePicker {
            
            selectedDeadline = datePicker.date
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            tfTaskDeadline.text = formatter.string(from: datePicker.date)
            
            dismiss(animated: true)
        }
    }
    
    @objc private func cancelDateSelection() {
        dismiss(animated: true)
    }
    
    private func addDoneButtonToTextFields() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
        
        tfTaskTitle.inputAccessoryView = toolbar
        tfTaskDescription.inputAccessoryView = toolbar
    }
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
    
    // MARK: - IBActions Add task button
    @IBAction func didTapAddTaskButton(_ sender: Any) {
           guard let taskTitle = tfTaskTitle.text, !taskTitle.isEmpty else {
               showRedView(view: tfTaskTitle)
               showCustomAlert(title: "Error", message: "Please enter task title", viewController: self)
               return
           }
           
           // Description is optional - use empty string if not provided
           let taskDescription = tfTaskDescription.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
           
           if let editingTask = editingTask {
               // UPDATE existing task
               updateExistingTask(editingTask, newTitle: taskTitle, newDescription: taskDescription)
           } else {
               // ADD new task
               addNewTask(title: taskTitle, description: taskDescription)
           }
       }
    
    private func addNewTask(title: String, description: String) {
        // Show loading state
        btnAddTask.isEnabled = false
        btnAddTask.setTitle("Adding...", for: .normal)
        
        // Create task with optional deadline
        let todoTask = TodoTask(title: title, description: description, deadline: selectedDeadline)
        
        // Use the ViewModel to add task
        taskViewModel.addTask(todoTask)
        
        // Show success message
        showToast(message: "Task added successfully!", duration: 2.0, color: AppTheme.Colors.secondary.withAlphaComponent(0.8), isTop: false)
        
        // Dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - IBAction Nav back button
    @IBAction func didTapNavBackButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
// MARK: Helper Methods.
extension AddNewTaskVC  {
    private func updateExistingTask(_ task: TodoTask, newTitle: String, newDescription: String) {
            // Show loading state
            btnAddTask.isEnabled = false
            btnAddTask.setTitle("Updating...", for: .normal)
            
            // Update task properties
            var updates: [String: Any] = [
                "title": newTitle,
                "Taskdescription": newDescription,
                "updatedAt": Date()
            ]
            
            // Update deadline if provided
            if let deadline = selectedDeadline {
                updates["deadline"] = deadline
            }
            
            // Use ViewModel to update task
            // You'll need to add this method to your TaskViewModel
            if taskViewModel.updateTask(task, updates: updates) {
                showToast(message: "Task updated successfully!", duration: 2.0, color: AppTheme.Colors.primary.withAlphaComponent(0.8), isTop: false)
            } else {
                showToast(message: "Failed to update task", duration: 2.0, color: UIColor.systemRed.withAlphaComponent(0.8), isTop: false)
            }
            
            // Dismiss after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.dismiss(animated: true)
            }
        }
}
// MARK: - UITextField Delegate
extension AddNewTaskVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Prevent keyboard from appearing for deadline field
        // User should tap the calendar button instead
        if textField == tfTaskDeadline {
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Clear red border when user starts editing
        showClearView(view: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfTaskTitle:
            tfTaskDescription.becomeFirstResponder()
        case tfTaskDescription:
            tfTaskDeadline.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - UITextField Padding Extension
extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
