//
//  NotificationManager.swift
//  YourQuickToDo
//
//  Manages local push notifications for task deadlines
//

import Foundation
import UserNotifications

class NotificationManager: NSObject {
    
    // MARK: - Singleton
    
    static let shared = NotificationManager()
    
    // MARK: - Properties
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Notification Categories
    
    private enum NotificationCategory {
        static let taskDeadline = "TASK_DEADLINE"
    }
    
    // MARK: - Notification Actions
    
    private enum NotificationAction {
        static let markComplete = "MARK_COMPLETE"
        static let snooze = "SNOOZE"
    }
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        setupNotificationCategories()
    }
    
    // MARK: - Setup
    
    private func setupNotificationCategories() {
        // Define actions
        let markCompleteAction = UNNotificationAction(
            identifier: NotificationAction.markComplete,
            title: "Mark Complete",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: NotificationAction.snooze,
            title: "Snooze 1 hour",
            options: []
        )
        
        // Define category
        let taskDeadlineCategory = UNNotificationCategory(
            identifier: NotificationCategory.taskDeadline,
            actions: [markCompleteAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Register categories
        notificationCenter.setNotificationCategories([taskDeadlineCategory])
    }
    
    // MARK: - Permission
    
    /// Request notification permission from user
    /// - Parameter completion: Callback with granted status
    func requestPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Notification permission error: \(error)")
            }
            
            print(granted ? "✅ Notification permission granted" : "⚠️ Notification permission denied")
            completion(granted)
        }
    }
    
    /// Check current notification authorization status
    /// - Parameter completion: Callback with authorization status
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
    
    // MARK: - Schedule Notifications
    
    /// Schedule a notification for a task deadline
    /// - Parameters:
    ///   - task: The task to schedule notification for
    ///   - minutesBefore: Minutes before deadline to notify (default: 60)
    func scheduleTaskDeadlineNotification(for task: TodoTask, minutesBefore: Int = 60) {
        guard let deadline = task.deadline else {
            print("⚠️ Task has no deadline, skipping notification")
            return
        }
        
        // Calculate notification time
        let notificationDate = deadline.addingTimeInterval(-Double(minutesBefore * 60))
        
        // Don't schedule if notification time is in the past
        guard notificationDate > Date() else {
            print("⚠️ Notification time is in the past, skipping")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Task Deadline Reminder"
        content.body = task.title
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.taskDeadline
        content.userInfo = [
            "taskId": task.id.stringValue,
            "taskTitle": task.title
        ]
        
        // Create trigger
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create request
        let identifier = "task_\(task.id.stringValue)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ Scheduled notification for task: \(task.title) at \(notificationDate)")
            }
        }
    }
    
    /// Schedule multiple notifications for a task (e.g., 1 day before, 1 hour before)
    /// - Parameter task: The task to schedule notifications for
    func scheduleMultipleNotifications(for task: TodoTask) {
        guard let deadline = task.deadline else { return }
        
        let now = Date()
        let timeUntilDeadline = deadline.timeIntervalSince(now)
        
        // If deadline is in the past, don't schedule
        guard timeUntilDeadline > 0 else {
            print("⚠️ Deadline is in the past, skipping notification")
            return
        }
        
        // For deadlines within the next hour, notify AT the deadline
        if timeUntilDeadline <= 60 * 60 {
            scheduleNotificationAtDeadline(for: task)
            print("📅 Scheduled notification AT deadline (within 1 hour)")
        }
        // For deadlines more than 1 hour but less than 24 hours away
        else if timeUntilDeadline <= 24 * 60 * 60 {
            // Notify 1 hour before
            scheduleTaskDeadlineNotification(for: task, minutesBefore: 60)
            print("📅 Scheduled notification 1 hour before deadline")
        }
        // For deadlines more than 24 hours away
        else {
            // Notify 1 day before AND 1 hour before
            scheduleTaskDeadlineNotification(for: task, minutesBefore: 24 * 60)
            scheduleTaskDeadlineNotification(for: task, minutesBefore: 60)
            print("📅 Scheduled notifications 1 day and 1 hour before deadline")
        }
    }
    
    /// Schedule a notification exactly at the deadline time
    /// - Parameter task: The task to schedule notification for
    private func scheduleNotificationAtDeadline(for task: TodoTask) {
        guard let deadline = task.deadline else { return }
        
        // Don't schedule if deadline is in the past
        guard deadline > Date() else {
            print("⚠️ Deadline is in the past, skipping notification")
            return
        }
        
        // CRITICAL: Extract properties BEFORE async call to avoid Realm threading issues
        let taskId = task.id.stringValue
        let taskTitle = task.title
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "⏰ Task Deadline Now!"
        content.body = taskTitle  // Use extracted value
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.taskDeadline
        content.userInfo = [
            "taskId": taskId,  // Use extracted value
            "taskTitle": taskTitle  // Use extracted value
        ]
        
        // Create trigger at exact deadline time
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: deadline)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create request with unique identifier for deadline notification
        let identifier = "task_deadline_\(taskId)"  // Use extracted value
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Error scheduling deadline notification: \(error)")
            } else {
                print("✅ Scheduled notification AT deadline for: \(taskTitle) at \(deadline)")  // Use extracted value
            }
        }
    }
    
    // MARK: - Cancel Notifications
    
    /// Cancel notification for a specific task
    /// - Parameter taskId: The task ID
    func cancelNotification(for taskId: String) {
        let identifier = "task_\(taskId)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("✅ Cancelled notification for task: \(taskId)")
    }
    
    /// Cancel all pending notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("✅ Cancelled all pending notifications")
    }
    
    // MARK: - Handle Notification Actions
    
    /// Handle notification action response
    /// - Parameters:
    ///   - response: The notification response
    ///   - completion: Completion handler
    func handleNotificationResponse(_ response: UNNotificationResponse, completion: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        guard let taskId = userInfo["taskId"] as? String else {
            completion()
            return
        }
        
        switch response.actionIdentifier {
        case NotificationAction.markComplete:
            handleMarkComplete(taskId: taskId)
            
        case NotificationAction.snooze:
            handleSnooze(taskId: taskId)
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification
            print("📱 User tapped notification for task: \(taskId)")
            
        default:
            break
        }
        
        completion()
    }
    
    private func handleMarkComplete(taskId: String) {
        print("✅ Mark complete action for task: \(taskId)")
        // Post notification to update task in the app
        NotificationCenter.default.post(
            name: NSNotification.Name("MarkTaskComplete"),
            object: nil,
            userInfo: ["taskId": taskId]
        )
    }
    
    private func handleSnooze(taskId: String) {
        print("⏰ Snooze action for task: \(taskId)")
        // Reschedule notification for 1 hour later
        // This would require fetching the task and rescheduling
        NotificationCenter.default.post(
            name: NSNotification.Name("SnoozeTask"),
            object: nil,
            userInfo: ["taskId": taskId]
        )
    }
    
    // MARK: - Debug
    
    /// Get all pending notifications (for debugging)
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            print("📋 Pending notifications: \(requests.count)")
            for request in requests {
                print("  - \(request.identifier): \(request.content.title)")
            }
            completion(requests)
        }
    }
}
