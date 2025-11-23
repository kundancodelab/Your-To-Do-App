//
//  MainTabBarController.swift
//  YourQuickToDo
//
//  Main Tab Bar Controller with 4 tabs
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🚀 MainTabBarController: viewDidLoad")
        view.backgroundColor = AppTheme.Colors.background
        
        // Configure Tab Bar Appearance
        tabBar.tintColor = AppTheme.Colors.primary
        tabBar.unselectedItemTintColor = AppTheme.Colors.textSecondary
        tabBar.backgroundColor = AppTheme.Colors.cardBackground
    }
    
    
}
