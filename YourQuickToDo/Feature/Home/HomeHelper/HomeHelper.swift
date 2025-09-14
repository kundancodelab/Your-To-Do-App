//
//  HomeHelper.swift
//  YourQuickToDo
//
//  Created by User on 15/09/25.
//

import Foundation

class DateFormatterHelper{
     func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
