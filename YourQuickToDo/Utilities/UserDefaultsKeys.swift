//
//  UserDefaultsKeys.swift
//  YourQuickToDo
//
//  Created by User on 23/11/25.
//

import Foundation

struct UserDefaultsKeys {
    
    // MARK: - Onboarding
    static let isOnboardingCompleted = "isOnboardingCompleted"
    
    // MARK: - App Settings
    static let notificationsEnabled = "notificationsEnabled"
    
    // MARK: - User Preferences
    // static let preferredTaskSortOrder = "preferredTaskSortOrder"
}

// MARK: - UserDefaults Extension for convenient access
extension UserDefaults {
    
    var isOnboardingCompleted: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.isOnboardingCompleted)
        }
        set {
            set(newValue, forKey: UserDefaultsKeys.isOnboardingCompleted)
        }
    }
    
    var notificationsEnabled: Bool {
        get {
            return bool(forKey: UserDefaultsKeys.notificationsEnabled)
        }
        set {
            set(newValue, forKey: UserDefaultsKeys.notificationsEnabled)
        }
    }
}
