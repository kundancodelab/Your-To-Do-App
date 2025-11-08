//
//  AddNewTaskVC.swift
//  YourQuickToDo
//
//  Created by User on 15/09/25.
//

import UIKit

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
    
    // MARK: - Dependencies
    var taskViewModel: TaskViewModel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupDatePicker()
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
    
    private func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        tfTaskDeadline.inputView = datePicker
        
        // Add toolbar with Done button specifically for date picker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerDoneTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(datePickerCancelTapped))
        toolbar.items = [cancelButton, flexibleSpace, doneButton]
        tfTaskDeadline.inputAccessoryView = toolbar
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        tfTaskDeadline.text = formatter.string(from: sender.date)
    }
    
    @objc private func datePickerDoneTapped() {
        // If no date selected yet, set to current date
        if tfTaskDeadline.text?.isEmpty ?? true {
            dateChanged(UIDatePicker())
        }
        tfTaskDeadline.resignFirstResponder()
    }
    
    @objc private func datePickerCancelTapped() {
        tfTaskDeadline.text = "" // Clear if cancelled
        tfTaskDeadline.resignFirstResponder()
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
        
        guard let taskDescription = tfTaskDescription.text, !taskDescription.isEmpty else {
            showRedView(view: tfTaskDescription)
            showCustomAlert(title: "Error", message: "Please enter task description", viewController: self)
            return
        }
        
        // Create and add the task
        addNewTask(title: taskTitle, description: taskDescription)
    }
    
    private func addNewTask(title: String, description: String) {
        // Show loading state
        btnAddTask.isEnabled = false
        btnAddTask.setTitle("Adding...", for: .normal)
        
        // Create task with optional deadline
        let todoTask = TodoTask(title: title, description: description)
        
        // Add deadline if provided
        if let deadlineText = tfTaskDeadline.text, !deadlineText.isEmpty {
            // Parse the deadline date from text
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            if let deadlineDate = formatter.date(from: deadlineText) {
                // You'll need to add deadline property to your TodoTask model
                // todoTask.deadline = deadlineDate
                print("📅 Task deadline: \(deadlineDate)")
            }
        }
        
        // Use the ViewModel to add task
        taskViewModel.addTask(todoTask)
        
        // Show success message
        showToast(message: "Task added successfully!", duration: 2.0, color: UIColor.systemGreen.withAlphaComponent(0.8), isTop: false)
        
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

// MARK: - UITextField Delegate
extension AddNewTaskVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Clear red border when user starts editing
        showClearView(view: textField)
        
        // Auto-set current date when deadline field is tapped
        if textField == tfTaskDeadline && textField.text?.isEmpty ?? true {
            dateChanged(UIDatePicker())
        }
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
