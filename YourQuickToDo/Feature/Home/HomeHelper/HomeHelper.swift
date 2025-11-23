//
//  HomeHelper.swift
//  YourQuickToDo
//
//  Created by User on 15/09/25.
//

import Foundation

class DateFormatterHelper {
    // Shared formatter for efficiency
    private static let shared = DateFormatterHelper()
    
    // MARK: - Main Format Method
    /// Formats a date to the user's local timezone and locale
    /// Example: "Nov 23, 2025 at 4:30 PM" (in user's timezone)
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        // Explicitly use device timezone (this is the default, but being explicit for clarity)
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    // MARK: - Additional Formatting Methods
    
    /// Formats date without time
    /// Example: "Nov 23, 2025"
    func formatDateOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    /// Formats time only
    /// Example: "4:30 PM"
    func formatTimeOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    /// Debug method to show timezone info
    func debugDateInfo(_ date: Date) -> String {
        let timezone = TimeZone.current
        return "Date: \(formatDate(date)), Timezone: \(timezone.identifier), Offset: \(timezone.secondsFromGMT() / 3600)h"
    }
}
