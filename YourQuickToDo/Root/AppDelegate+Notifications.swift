//
//  AppDelegate+Notifications.swift
//  YourQuickToDo
//
//  Extension for handling notification delegate methods
//

import UIKit
import UserNotifications

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// Called when a notification is delivered to a foreground app
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("📬 Notification received in foreground: \(notification.request.content.title)")
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Called when user interacts with a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("📱 User interacted with notification: \(response.actionIdentifier)")
        
        // Handle notification response
        NotificationManager.shared.handleNotificationResponse(response, completion: completionHandler)
    }
}
