//
//  ProfileRouter.swift
//  YourQuickToDo
//
//  Profile Feature Navigation Flow
//

import UIKit

// MARK: - Profile Flow Destinations

/// Defines all possible navigation destinations within the Profile feature
enum ProfileFlow: NavigationDestination {
    case settings
    case notificationSettings
    case about
    
    // MARK: - NavigationDestination Conformance
    
    var title: String {
        switch self {
        case .settings:
            return "Settings"
        case .notificationSettings:
            return "Notification Settings"
        case .about:
            return "About"
        }
    }
    
    func createViewController() -> UIViewController {
        switch self {
        case .settings:
            return createSettingsViewController()
            
        case .notificationSettings:
            return createNotificationSettingsViewController()
            
        case .about:
            return createAboutViewController()
        }
    }
    
    // MARK: - Private Factory Methods
    
    private func createSettingsViewController() -> UIViewController {
        // TODO: Create dedicated SettingsVC
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Settings (Coming Soon)"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
    }
    
    private func createNotificationSettingsViewController() -> UIViewController {
        // TODO: Create dedicated NotificationSettingsVC
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Notification Settings (Coming Soon)"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
    }
    
    private func createAboutViewController() -> UIViewController {
        return AboutVC()
    }
}

// MARK: - Hashable Conformance

extension ProfileFlow: Hashable {
    static func == (lhs: ProfileFlow, rhs: ProfileFlow) -> Bool {
        switch (lhs, rhs) {
        case (.settings, .settings),
             (.notificationSettings, .notificationSettings),
             (.about, .about):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .settings:
            hasher.combine("settings")
        case .notificationSettings:
            hasher.combine("notificationSettings")
        case .about:
            hasher.combine("about")
        }
    }
}

// MARK: - Type Alias

/// Type alias for cleaner usage
typealias ProfileRouter = Router<ProfileFlow>
