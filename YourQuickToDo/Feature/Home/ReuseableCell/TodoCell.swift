//
//  TodoCell.swift
//  YourQuickToDo
//
//  Created by User on 14/09/25.
//

import UIKit

class TodoCell: UITableViewCell {
    
    /// Container view
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.systemGray.cgColor
            containerView.layer.cornerRadius = 8 // Optional: add rounded corners
            containerView.clipsToBounds = true // Optional: needed for cornerRadius to work
        }
    }
    /// TitleLbl
    @IBOutlet weak var titleLbl: UILabel!
    /// Description Lbl
    @IBOutlet weak var descriptonLbl: UILabel!
    /// Date lbl
    @IBOutlet weak var dateLbl: UILabel!
    /// check mark button for compeletiong the task.
    @IBOutlet weak var checkMarkButton: UIButton!
    /// Edit button to edit the task
    @IBOutlet weak var editButton: UIButton!
    /// Delete button to delete the task
    @IBOutlet weak var deleteButton: UIButton!
    
    /// Callback closure for edit button
    var editButtonTapped: (() -> Void)?
    
    /// Callback Closure for mark complete button
    var markCompleteButtonTapped:(() -> Void)?
    
    /// Callback closure for deletting the task
    var deleteButtonTapped:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(with todo: TodoTask) {
        let isDone = todo.isCompleted
        checkMarkButton.setImage(UIImage(systemName: isDone ? "checkmark.circle.fill" : "checkmark.circle" ), for: .normal)
        checkMarkButton.tintColor = isDone ? .systemGreen : .black 
        titleLbl.text = todo.title
        
        // Show description only if it's not empty
        if !todo.Taskdescription.isEmpty {
            descriptonLbl.isHidden = false
            descriptonLbl.text = todo.Taskdescription
        } else {
            descriptonLbl.isHidden = true
            descriptonLbl.text = nil
        }
        
        // Show deadline if present, otherwise hide the date label
        if let deadline = todo.deadline {
            dateLbl.isHidden = false
            dateLbl.text = "\(DateFormatterHelper().formatDate(deadline))"
        } else {
            dateLbl.isHidden = true
            dateLbl.text = nil
        }
    }
    
    
  // MARK:  IBAction Edit Button
    
    @IBAction func didTapEditButton(_ sender: Any) {
      
        editButtonTapped?()
    }
    
    // MARK: IBAction Delete Button
    
    @IBAction func didTapDeleteButton(_ sender: Any) {
   
        deleteButtonTapped?()
    }
    
    // MARK: IBAction Complete Task Button
    @IBAction func didTapCompleteTaskButton(_ sender: Any) {
        
        markCompleteButtonTapped?()
    }
}



